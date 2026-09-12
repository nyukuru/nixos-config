#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os
import re
import subprocess

import libcalamares

NIXOS_CONFIG = "/home/nixos/nixos-config"
HARDWARE_FACTS = "/run/detected-hardware.json"
SECRETS_PATH = "/run/calamares-secrets.json"
LUKS_KEYFILE = "/tmp/secret.key"

GPU_PAIRS = {
    "intel": ("intel", "intel"),
    "amd": ("amd", "amd"),
    "nvidia-intel": ("intel", "nvidia"),
    "nvidia-amd": ("amd", "nvidia"),
}

NEW_USER_EXTRA_GROUPS = [
    "wheel",
    "systemd-journal",
    "audio",
    "video",
    "input",
    "docker",
    "power",
    "network",
    "nix",
    "networkmanager",
]


def gs(key, default=None):
    value = libcalamares.globalstorage.value(key)
    return value if value not in (None, "") else default


def load_json(path, default):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return default


def picked(key, facts_key, facts):
    """A manual packagechooser@key page wins if it was shown; otherwise
    fall back to what the launcher auto-detected before Calamares started."""
    value = gs(f"packagechooser_{key}")
    if value and value != "none":
        return value
    if value == "none":
        return None
    return facts.get(facts_key)


def render_hardware_block(cpu, gpu_choice, facts):
    if gpu_choice == "none":
        igpu = dgpu = None
    elif gpu_choice in GPU_PAIRS:
        igpu, dgpu = GPU_PAIRS[gpu_choice]
    else:
        igpu = facts.get("igpu")
        dgpu = facts.get("dgpu")

    if not cpu or not igpu or not dgpu:
        return "hardware.enableAllHardware = true;"

    block = (
        "nyu.hardware = {\n"
        f'    cpu = "{cpu}";\n'
        f'    igpu = "{igpu}";\n'
        f'    dgpu = "{dgpu}";\n'
        "  };"
    )

    if dgpu == "nvidia":
        nvidia_bus_id = facts.get("nvidiaBusId")
        igpu_bus_id = facts.get("igpuBusId")
        if nvidia_bus_id and igpu_bus_id:
            igpu_bus_id_key = "amdgpuBusId" if igpu == "amd" else "intelBusId"
            block += (
                "\n\n  hardware.nvidia.prime = {\n"
                f'    nvidiaBusId = "{nvidia_bus_id}";\n'
                f'    {igpu_bus_id_key} = "{igpu_bus_id}";\n'
                "  };"
            )

    return block


def to_posix_locale(bcp47):
    return bcp47.replace("-", "_") + ".UTF-8" if bcp47 else "en_US.UTF-8"


BTRFS_DISK_CONFIG = """{{inputs, ...}}: {{
  imports = [inputs.disko.nixosModules.default];

  disko.devices = {{
    disk = {{
      main = {{
        type = "disk";
        device = "{device}";
        content = {{
          type = "gpt";
          partitions = {{
            ESP = {{
              size = "2G";
              type = "EF00";
              content = {{
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              }};
            }};
            luks = {{
              size = "100%";
              content = {{
                type = "luks";
                name = "crypted-1";
                passwordFile = "{keyfile}";
                settings.crypttabExtraOpts = ["tpm2-device=auto"];
                content = {{
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {{
                    "/root" = {{
                      mountpoint = "/";
                      mountOptions = ["subvol=root" "compress=zstd" "noatime"];
                    }};
                    "/home" = {{
                      mountpoint = "/home";
                      mountOptions = ["subvol=home" "compress=zstd" "noatime"];
                    }};
                    "/nix" = {{
                      mountpoint = "/nix";
                      mountOptions = ["subvol=nix" "compress=zstd" "noatime"];
                    }};
                    "/swap" = {{
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "16G";
                    }};
                  }};
                }};
              }};
            }};
          }};
        }};
      }};
    }};
  }};
}}
"""

PLAIN_DISK_CONFIG = """{{inputs, ...}}: {{
  imports = [inputs.disko.nixosModules.default];

  disko.devices = {{
    disk = {{
      main = {{
        type = "disk";
        device = "{device}";
        content = {{
          type = "gpt";
          partitions = {{
            ESP = {{
              size = "2G";
              type = "EF00";
              content = {{
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              }};
            }};
            luks = {{
              size = "100%";
              content = {{
                type = "luks";
                name = "crypted-1";
                passwordFile = "{keyfile}";
                settings.crypttabExtraOpts = ["tpm2-device=auto"];
                content = {{
                  type = "filesystem";
                  format = "{filesystem}";
                  mountpoint = "/";
                }};
              }};
            }};
          }};
        }};
      }};
    }};
  }};
}}
"""


def find_attr_block(content, name):
    """Locate `name = { ... };` in a Nix attrset's text and return (start, end)
    spanning the whole block including the trailing ';', or None if absent."""
    match = re.search(rf"(?m)^\s*{re.escape(name)}\s*=\s*\{{", content)
    if not match:
        return None

    depth = 0
    i = match.end() - 1
    while i < len(content):
        if content[i] == "{":
            depth += 1
        elif content[i] == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    end = i + 1
    if end < len(content) and content[end] == ";":
        end += 1
    return match.start(), end


def upsert_user(users_content, username, hashed_password, extra_groups):
    block_span = find_attr_block(users_content, username)
    if block_span is not None:
        start, end = block_span
        block = users_content[start:end]
        pw_line = f'initialHashedPassword = "{hashed_password}";'
        if re.search(r'initialHashedPassword\s*=\s*"[^"]*";', block):
            block = re.sub(r'initialHashedPassword\s*=\s*"[^"]*";', pw_line, block)
        else:
            block = re.sub(r"\{\s*\n", "{\n    " + pw_line + "\n", block, count=1)
        return users_content[:start] + block + users_content[end:]

    if not users_content.rstrip().endswith("}"):
        raise ValueError("hosts/users.nix did not end with '}' as expected.")
    groups_nix = " ".join(f'"{g}"' for g in extra_groups)
    new_user = (
        f"\n\n  {username} = {{\n"
        "    isNormalUser = true;\n"
        f"    extraGroups = [{groups_nix}];\n"
        f'    initialHashedPassword = "{hashed_password}";\n'
        "  };\n"
    )
    return users_content.rstrip()[:-1] + new_user + "}\n"


def run():
    facts = load_json(HARDWARE_FACTS, {})
    secrets = load_json(SECRETS_PATH, None)
    if secrets is None:
        return ("nixos-config-generate failed", f"{SECRETS_PATH} is missing.")

    hostname = gs("hostname")
    username = gs("username")
    if not hostname or not username:
        return ("nixos-config-generate failed", "hostname or username was not set.")

    disk = gs("packagechooser_disk")
    filesystem = gs("packagechooser_filesystem", "btrfs")
    cpu = picked("cpu", "cpu", facts)
    gpu_choice = gs("packagechooser_gpu")
    forms = (gs("packagechooser_forms", "graphical") or "graphical").split(",")
    theme = gs("packagechooser_theme", "nyubones")
    locale = to_posix_locale(gs("locale"))
    keymap = gs("keyboardLayout", "us")

    hashed_password = subprocess.run(
        ["mkpasswd", "-m", "sha512crypt", "--stdin"],
        input=secrets["loginPassword"].encode(),
        capture_output=True,
        check=True,
    ).stdout.decode().strip()

    fd = os.open(LUKS_KEYFILE, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        f.write(secrets["luksPassword"])

    try:
        os.remove(SECRETS_PATH)
    except FileNotFoundError:
        pass

    host_dir = os.path.join(NIXOS_CONFIG, "hosts", hostname)
    os.makedirs(host_dir, exist_ok=True)

    with open(os.path.join(host_dir, "default.nix"), "w") as f:
        f.write(
            "{lib, ...}: {\n"
            "  imports = [\n"
            "    ./disk-config.nix\n"
            "    ./programs.nix\n"
            "    ./services.nix\n"
            "    ./system.nix\n"
            "  ];\n\n"
            f'  i18n.defaultLocale = "{locale}";\n'
            f'  console.keyMap = "{keymap}";\n\n'
            "  system.stateVersion = lib.trivial.release;\n"
            "}\n"
        )

    with open(os.path.join(host_dir, "system.nix"), "w") as f:
        f.write("{...}: {\n  " + render_hardware_block(cpu, gpu_choice, facts) + "\n}\n")

    with open(os.path.join(host_dir, "programs.nix"), "w") as f:
        if "graphical" in forms:
            f.write("{...}: {\n  nyu.programs.niri.enable = true;\n}\n")
        else:
            f.write("{...}: {}\n")

    with open(os.path.join(host_dir, "services.nix"), "w") as f:
        f.write("{...}: {}\n")

    template = BTRFS_DISK_CONFIG if filesystem == "btrfs" else PLAIN_DISK_CONFIG
    with open(os.path.join(host_dir, "disk-config.nix"), "w") as f:
        f.write(template.format(device=disk, keyfile=LUKS_KEYFILE, filesystem=filesystem))

    users_path = os.path.join(NIXOS_CONFIG, "hosts", "users.nix")
    with open(users_path) as f:
        users_content = f.read()
    try:
        users_content = upsert_user(users_content, username, hashed_password, NEW_USER_EXTRA_GROUPS)
    except ValueError as e:
        return ("nixos-config-generate failed", str(e))
    with open(users_path, "w") as f:
        f.write(users_content)

    default_path = os.path.join(NIXOS_CONFIG, "hosts", "default.nix")
    with open(default_path) as f:
        default_content = f.read()
    marker = "\n  };\n\n  perSystem"
    if marker not in default_content:
        return (
            "nixos-config-generate failed",
            "hosts/default.nix did not match the expected shape for inserting a new host.",
        )
    forms_nix = " ".join(f'"{f}"' for f in forms)
    new_host_entry = (
        f"\n\n    {hostname} = mkNixosSystem {{\n"
        f'      hostname = "{hostname}";\n'
        '      system = "x86_64-linux";\n'
        f'      users = ["{username}"];\n'
        "      modules = mkModules {\n"
        f"        form = [{forms_nix}];\n"
        f'        theme = "{theme}";\n'
        "        extraModules = [disko];\n"
        "      };\n"
        "    };"
    )
    default_content = default_content.replace(marker, new_host_entry + marker, 1)
    with open(default_path, "w") as f:
        f.write(default_content)

    libcalamares.globalstorage.insert("nyuHostname", hostname)
    return None
