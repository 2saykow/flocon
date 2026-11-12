# Flocon

An operating system based on NixOS 26.05, with the Cinnamon desktop (the one from Linux Mint), its own logo, wallpaper and theme, and a graphical installer.

![Flocon desktop](branding/desktop-preview.png)

## Build

You need [Nix](https://nixos.org/download) (on Arch: `sudo pacman -S nix`).

```bash
./build iso   # bootable ISO: result-iso/iso/flocon-26.05-x86_64.iso
./build vm    # try Flocon in a virtual machine
```

To put the ISO on a USB stick, copy it to a [Ventoy](https://www.ventoy.net) stick or use `dd`.

## Contents

- `configuration.nix`: the system (desktop, network, applications, visual identity)
- `installer.nix`: the ISO and the Calamares installer in Flocon colours
- `branding/`: logos and images; `python3 branding/generate.py` regenerates them
- `installer-test`: boots the ISO in QEMU with two test disks

## Contact

Enjoyed the project? Say hi on Telegram: [@Obs3rvateur](https://t.me/Obs3rvateur)

## License

MIT
