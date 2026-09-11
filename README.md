## Hosts
| Name         | Description                                |  Form   | Architecture  |
| :----------- | :-----------------------------------------:| :-----: | :-----------: |
| `vessel`     | XPS 15 9520 Daily carry laptop.            | Laptop  | x86_64-linux  |
| `carbon`     | Live/installer medium, built with `nix build .#carbon-iso`. | ISO | x86_64-linux |

## Live/installer medium

Booting the `carbon` image (`nix build .#carbon-iso`) gives a ready-to-use
sway desktop. Every boot, `~/nixos-config` is freshly reset from the
snapshot of this repo baked into the image (`/nixos-config-snapshot`), so
edits made during a session don't linger into the next one.

To install onto another machine:
1. Edit `~/nixos-config` to add `hosts/<hostname>/` (`disk-config.nix`,
   `default.nix`, ...; use `nixos-generate-config --no-filesystems` for
   hardware detection) and register it in `hosts/default.nix`.
2. Run:
   ```
   installer .#<hostname>
   ```
   `.` resolves to `~/nixos-config`. This builds `<hostname>`'s toplevel
   closure to validate it, disko's the disk(s) declared in
   `hosts/<hostname>/disk-config.nix` (destroying their contents once you
   confirm), runs `nixos-install`, and copies `nixos-config` into every
   normal user's home directory on the new system.

