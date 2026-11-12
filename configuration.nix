# Flocon — system configuration, shared by the test VM and the ISO.
{ pkgs, lib, ... }:
{
  system.nixos.distroName = "Flocon";
  networking.hostName = lib.mkDefault "flocon";

  # Network: NetworkManager handles real Wi-Fi and Ethernet cards.
  networking.networkmanager.enable = true;
  # Firmware for common Wi-Fi/Bluetooth cards (Intel, Realtek, Atheros…), needed on real hardware.
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  # Defaults: the installer replaces them with the user's choices.
  time.timeZone = lib.mkDefault "UTC";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";

  # Cinnamon desktop (the one from Linux Mint), LightDM login screen.
  services.xserver = {
    enable = true;
    xkb.layout = lib.mkDefault "us";
    desktopManager.cinnamon.enable = true;
    displayManager.lightdm.enable = true;
  };

  # Visual identity: boot logo, wallpaper (desktop + login screen), glacier-blue theme.
  boot.plymouth = { enable = true; logo = ./branding/logo.png; };
  boot.kernelParams = [ "quiet" "splash" ];   # silent boot, otherwise the text log hides the logo
  boot.consoleLogLevel = 3;
  boot.loader.grub.splashImage = ./branding/boot-efi.png;   # boot menu of the installed system
  services.xserver.displayManager.lightdm.background = ./branding/wallpaper.png;
  services.xserver.displayManager.lightdm.greeters.slick.extraConfig = "logo=${./branding/logo-text.png}";

  # Replaces the NixOS logo ("nix-snowflake" icon, used by the system and its applications) with Flocon's.
  nixpkgs.overlays = [
    (final: prev: {
      nixos-icons = prev.nixos-icons.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.librsvg ];
        postInstall = (old.postInstall or "") + ''
          for f in $(find $out -name 'nix-snowflake*.png'); do
            rsvg-convert -w "$(basename "$(dirname "$(dirname "$f")")" | cut -dx -f1)" ${./branding/logo.svg} -o "$f"
          done
          for f in $(find $out -name 'nix-snowflake*.svg'); do cp ${./branding/logo.svg} "$f"; done
        '';
      });
    })
  ];
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/cinnamon/desktop/background" = {
        picture-uri = "file://${./branding/wallpaper.png}";
        picture-options = "zoom";
      };
      "org/cinnamon/desktop/interface" = { gtk-theme = "Mint-Y-Dark-Aqua"; icon-theme = "Mint-Y-Aqua"; };
      "org/cinnamon/theme".name = "Mint-Y-Dark-Aqua";
      # The menu reads its icon from this setting (default: cinnamon-symbolic).
      "org/cinnamon".app-menu-icon-name = "flocon-symbolic";
    };
  }];

  # Applications included out of the box (Cinnamon already brings files, images, PDF, text editor, calculator).
  environment.systemPackages = with pkgs; [
    firefox thunderbird libreoffice-fresh vlc git
    # Desktop menu icon: Flocon logo instead of Cinnamon's.
    (runCommand "flocon-menu-icon" { } ''
      install -Dm644 ${./branding/logo-symbolic.svg} $out/share/icons/hicolor/scalable/apps/flocon-symbolic.svg
    '')
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
