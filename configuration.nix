# Flocon — configuration du système, commune à la VM de test et à l'ISO.
{ pkgs, lib, ... }:
{
  system.nixos.distroName = "Flocon";
  networking.hostName = lib.mkDefault "flocon";

  # Réseau : NetworkManager gère les vraies cartes Wi-Fi et Ethernet.
  networking.networkmanager.enable = true;
  # Firmware des cartes Wi-Fi/Bluetooth courantes (Intel, Realtek, Atheros…), nécessaire sur une vraie machine.
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  # Valeurs par défaut : l'installateur les remplace par les choix de l'utilisateur.
  time.timeZone = lib.mkDefault "Europe/Paris";
  i18n.defaultLocale = lib.mkDefault "fr_FR.UTF-8";
  console.keyMap = lib.mkDefault "fr";

  # Bureau Cinnamon (celui de Linux Mint), écran de connexion LightDM.
  services.xserver = {
    enable = true;
    xkb.layout = lib.mkDefault "fr";
    desktopManager.cinnamon.enable = true;
    displayManager.lightdm.enable = true;
  };

  # Identité visuelle : logo au démarrage, fond d'écran (bureau + écran de connexion), thème bleu glacier.
  boot.plymouth = { enable = true; logo = ./branding/logo.png; };
  boot.kernelParams = [ "quiet" "splash" ];
  boot.loader.grub.splashImage = ./branding/boot-efi.png;   # menu de démarrage du système installé   # démarrage silencieux, sinon le journal texte masque le logo
  boot.consoleLogLevel = 3;
  services.xserver.displayManager.lightdm.background = ./branding/wallpaper.png;
  services.xserver.displayManager.lightdm.greeters.slick.extraConfig = "logo=${./branding/logo-texte.png}";

  # Remplace le logo NixOS (icône « nix-snowflake », utilisée par le système et ses applications) par celui de Flocon.
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
      # Le menu lit son icône dans ce réglage (défaut : cinnamon-symbolic).
      "org/cinnamon".app-menu-icon-name = "flocon-symbolic";
    };
  }];

  # Applications fournies d'office (Cinnamon apporte déjà fichiers, images, PDF, éditeur de texte, calculatrice).
  environment.systemPackages = with pkgs; [
    firefox thunderbird libreoffice-fresh vlc git
    # Icône du menu du bureau : logo Flocon à la place de celui de Cinnamon.
    (runCommand "flocon-icone-menu" { } ''
      install -Dm644 ${./branding/logo-symbolique.svg} $out/share/icons/hicolor/scalable/apps/flocon-symbolic.svg
    '')
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
