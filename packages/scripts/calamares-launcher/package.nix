{
  pkgs,
  pciutils,
  util-linux,
  branding,
}:
pkgs.writers.writePython3Bin "calamares-launcher" {flakeIgnore = ["E501"];} (
  builtins.replaceStrings
  [
    "@calamares@"
    "@lspci@"
    "@lsblk@"
  ]
  [
    "${branding.calamares-carbon}/bin/calamares"
    "${pciutils}/bin/lspci"
    "${util-linux}/bin/lsblk"
  ]
  ''
import json
import os
import re
import subprocess

CALAMARES = "@calamares@"
LSPCI = "@lspci@"
LSBLK = "@lsblk@"

ETC = "/etc/calamares"

CPU_VENDORS = {"GenuineIntel": "intel", "AuthenticAMD": "amd"}
GPU_VENDORS = {"8086": "intel", "1002": "amd", "10de": "nvidia"}


def esc(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')


def detect_cpu():
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("vendor_id"):
                    vendor = line.split(":", 1)[1].strip()
                    return CPU_VENDORS.get(vendor)
    except OSError:
        pass
    return None


GPU_CONTROLLER_KINDS = (
    "VGA compatible controller",
    "3D controller",
    "Display controller",
)


def detect_gpus():
    try:
        out = subprocess.run(
            [LSPCI, "-nn"], capture_output=True, text=True, check=True
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return []
    vendors = []
    for line in out.splitlines():
        if any(k in line for k in GPU_CONTROLLER_KINDS):
            m = re.search(r"\[([0-9a-f]{4}):[0-9a-f]{4}\]", line)
            if m and m.group(1) in GPU_VENDORS:
                vendors.append(GPU_VENDORS[m.group(1)])
    return vendors


def gpu_facts(vendors):
    vendors = [v for v in vendors if v]
    if not vendors:
        return {}
    if len(vendors) == 1:
        return {"igpu": vendors[0], "dgpu": vendors[0]}
    if "nvidia" in vendors:
        others = [v for v in vendors if v != "nvidia"]
        if others:
            return {"igpu": others[0], "dgpu": "nvidia"}
    return {}


def detect_disks():
    try:
        out = subprocess.run(
            [LSBLK, "-dno", "NAME,SIZE,MODEL", "-e", "7"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return []
    disks = []
    for line in out.splitlines():
        parts = line.split(None, 2)
        if not parts:
            continue
        name = parts[0]
        size = parts[1] if len(parts) > 1 else ""
        model = parts[2] if len(parts) > 2 else ""
        label = f"/dev/{name} - {size} {model}".strip()
        disks.append({"device": f"/dev/{name}", "label": label})
    return disks


def write_disk_conf(disks):
    if not disks:
        return
    items = "\n".join(
        f'    - id: "{esc(d["device"])}"\n'
        "      packages: []\n"
        f'      name: "{esc(d["label"])}"\n'
        '      description: ""'
        for d in disks
    )
    content = f''''mode: required
method: legacy

labels:
    step: "Disk"

default: "{esc(disks[0]["device"])}"

items:
{items}
''''
    os.makedirs(f"{ETC}/modules", exist_ok=True)
    with open(f"{ETC}/modules/packagechooser-disk.conf", "w") as f:
        f.write(content)


def write_settings_conf(show_cpu, show_gpu):
    hw_pages = []
    if show_cpu:
        hw_pages.append("  - packagechooser@cpu")
    if show_gpu:
        hw_pages.append("  - packagechooser@gpu")
    hw_pages_yaml = "\n".join(hw_pages)

    content = f''''instances:
- id: internet-help
  module: notesqml
  config: notesqml-internet-help.conf
- id: forms
  module: packagechooser
  config: packagechooser-forms.conf
- id: theme
  module: packagechooser
  config: packagechooser-theme.conf
- id: filesystem
  module: packagechooser
  config: packagechooser-filesystem.conf
- id: disk
  module: packagechooser
  config: packagechooser-disk.conf
- id: cpu
  module: packagechooser
  config: packagechooser-cpu.conf
- id: gpu
  module: packagechooser
  config: packagechooser-gpu.conf

sequence:
- show:
  - notesqml@internet-help
  - welcome
  - locale
  - keyboard
  - packagechooser@disk
  - packagechooser@filesystem
{hw_pages_yaml}
  - users
  - packagechooser@forms
  - packagechooser@theme
- exec:
  - collect-secrets
  - nixos-config-generate
  - nixos-config-install
- show:
  - finished

branding: carbon

prompt-install: false
dont-chroot: false
oem-setup: false
disable-cancel: false
disable-cancel-during-exec: true
hide-back-and-next-during-exec: false
quit-at-end: false
''''
    os.makedirs(ETC, exist_ok=True)
    with open(f"{ETC}/settings.conf", "w") as f:
        f.write(content)


def main():
    facts = {}
    cpu = detect_cpu()
    if cpu:
        facts["cpu"] = cpu
    facts.update(gpu_facts(detect_gpus()))

    os.makedirs("/run", exist_ok=True)
    with open("/run/detected-hardware.json", "w") as f:
        json.dump(facts, f)

    write_settings_conf(
        show_cpu="cpu" not in facts,
        show_gpu=not ("igpu" in facts and "dgpu" in facts),
    )
    write_disk_conf(detect_disks())

    # calamares needs root to see real block devices
    os.execvp(
        "sudo",
        ["sudo", "--preserve-env=WAYLAND_DISPLAY,XDG_RUNTIME_DIR", CALAMARES],
    )


if __name__ == "__main__":
    main()
  ''
)
