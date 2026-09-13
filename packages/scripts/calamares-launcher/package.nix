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
    "@findmnt@"
    "@modulesdir@"
  ]
  [
    "${branding.calamares-nyuos}/bin/calamares"
    "${pciutils}/bin/lspci"
    "${util-linux}/bin/lsblk"
    "${util-linux}/bin/findmnt"
    "${branding.calamares-nyuos.extensions}/lib/calamares/modules"
  ]
  ''
import json
import os
import re
import subprocess

CALAMARES = "@calamares@"
LSPCI = "@lspci@"
LSBLK = "@lsblk@"
FINDMNT = "@findmnt@"
MODULESDIR = "@modulesdir@"

BY_ID_DIR = "/dev/disk/by-id"
PREFERRED_ID_PREFIXES = ("nvme-", "ata-", "scsi-", "wwn-")

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


def to_bus_id(pci_addr):
    """Convert an lspci "domain:bus:device.function" address (e.g.
    "0000:01:00.0") to the NixOS X11 BusId format (e.g. "PCI:1:0:0")."""
    _domain, bus, rest = pci_addr.split(":")
    device, function = rest.split(".")
    return f"PCI:{int(bus, 16)}:{int(device, 16)}:{int(function, 16)}"


def detect_gpus():
    try:
        out = subprocess.run(
            [LSPCI, "-Dnn"], capture_output=True, text=True, check=True
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return []
    gpus = []
    for line in out.splitlines():
        if any(k in line for k in GPU_CONTROLLER_KINDS):
            addr_m = re.match(r"([0-9a-f]{4}:[0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f])", line)
            vendor_m = re.search(r"\[([0-9a-f]{4}):[0-9a-f]{4}\]", line)
            if addr_m and vendor_m and vendor_m.group(1) in GPU_VENDORS:
                gpus.append((addr_m.group(1), GPU_VENDORS[vendor_m.group(1)]))
    return gpus


def gpu_facts(gpus):
    if not gpus:
        return {}
    vendors = [v for _, v in gpus]
    if len(vendors) == 1:
        return {"igpu": vendors[0], "dgpu": vendors[0]}
    if "nvidia" in vendors:
        nvidia_addr = next(addr for addr, v in gpus if v == "nvidia")
        others = [(addr, v) for addr, v in gpus if v != "nvidia"]
        if others:
            igpu_addr, igpu_vendor = others[0]
            return {
                "igpu": igpu_vendor,
                "dgpu": "nvidia",
                "nvidiaBusId": to_bus_id(nvidia_addr),
                "igpuBusId": to_bus_id(igpu_addr),
            }
    return {}


def boot_medium_disk():
    """Name (e.g. "sda") of the disk backing the live installation medium,
    so it never shows up as an install target. NixOS live ISOs mount the
    medium itself at /iso."""
    try:
        src = subprocess.run(
            [FINDMNT, "-no", "SOURCE", "/iso"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return None
    if not src:
        return None
    try:
        pkname = subprocess.run(
            [LSBLK, "-dno", "PKNAME", src],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        pkname = ""
    return pkname or os.path.basename(src)


def stable_disk_path(name):
    """Resolve a kernel disk name (e.g. "nvme1n1") to a stable
    /dev/disk/by-id/... path. Kernel names like /dev/nvme0n1 aren't
    guaranteed to enumerate in the same order every boot, so baking one
    into a generated disk-config.nix can silently point at the wrong
    physical disk later. Falls back to the kernel name if no by-id link
    is found."""
    devpath = f"/dev/{name}"
    try:
        entries = os.listdir(BY_ID_DIR)
    except OSError:
        return devpath

    matches = []
    for entry in entries:
        if "-part" in entry:
            continue
        try:
            target = os.path.realpath(os.path.join(BY_ID_DIR, entry))
        except OSError:
            continue
        if os.path.basename(target) == name:
            matches.append(entry)

    if not matches:
        return devpath

    for prefix in PREFERRED_ID_PREFIXES:
        preferred = sorted(e for e in matches if e.startswith(prefix))
        if preferred:
            return f"{BY_ID_DIR}/{preferred[0]}"
    return f"{BY_ID_DIR}/{sorted(matches)[0]}"


def detect_disks():
    try:
        out = subprocess.run(
            [LSBLK, "-P", "-o", "NAME,SIZE,MODEL,TYPE", "-e", "7"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    except (OSError, subprocess.CalledProcessError):
        return []

    exclude = {boot_medium_disk()}

    disks = []
    for line in out.splitlines():
        fields = dict(re.findall(r'(\w+)="((?:[^"\\]|\\.)*)"', line))
        if not fields:
            continue
        if fields.get("TYPE") != "disk":
            continue
        name = fields.get("NAME", "")
        if not name or name in exclude or name.startswith("zram"):
            continue
        size = fields.get("SIZE", "")
        model = fields.get("MODEL", "")
        device = stable_disk_path(name)
        label = f"{device} - {size} {model}".strip()
        disks.append({"device": device, "label": label})
    return disks


def write_disk_conf(disks):
    if disks:
        default_line = f'default: "{esc(disks[0]["device"])}"'
        items = "\n".join(
            f'    - id: "{esc(d["device"])}"\n'
            "      packages: []\n"
            f'      name: "{esc(d["label"])}"\n'
            '      description: ""'
            for d in disks
        )
    else:
        default_line = ""
        items = (
            '    - id: ""\n'
            "      packages: []\n"
            '      name: "No disks detected"\n'
            '      description: "Hardware detection could not find any disks. '
            'Go back and check the internet-help step, or report this as a bug."'
        )
    content = f''''mode: required
method: legacy

labels:
    step: "Disk"

{default_line}

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

    content = f''''modules-search: [local, {MODULESDIR}]

instances:
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

branding: nyuos

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
