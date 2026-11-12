# Flocon — installation ISO: adds the Calamares graphical installer, adapted to install Flocon.
{ lib, options, ... }:
{
  services.displayManager.autoLogin = { enable = true; user = "nixos"; };
  image.baseName = lib.mkForce "flocon-26.05-x86_64";
  isoImage.volumeID = "FLOCON_26_05";

  # Boot menus of the USB stick: Flocon images, menu in white text on a dark background.
  isoImage.splashImage = ./branding/boot-bios.png;
  isoImage.efiSplashImage = ./branding/boot-efi.png;
  isoImage.grubTheme = null;   # the default theme shows the NixOS logo
  isoImage.syslinuxTheme = lib.replaceStrings [ "#FF000000" "#FF5277C3" ] [ "#FFFFFFFF" "#FF127A8A" ]
    options.isoImage.syslinuxTheme.default;

  nixpkgs.overlays = [
    (final: prev: {
      calamares-nixos-extensions = prev.calamares-nixos-extensions.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          # Flocon = Cinnamon: no desktop chooser page.
          sed -i '/- packagechooser/d; /- notesqml@unfree/d' config/settings.conf
          sed -i 's/gs.value("packagechooser_packagechooser")/"cinnamon"/g' modules/nixos/main.py
          # The installed system imports the Flocon config, copied to /etc/nixos/flocon.
          sed -i 's|^      ./hardware-configuration.nix$|&\n      ./flocon/configuration.nix|' modules/nixos/main.py
          sed -i 's|^    # build nixos-install command$|    subprocess.check_output(["pkexec", "cp", "-rL", "--no-preserve=mode", "@flocon@", root_mount_point + "/etc/nixos/flocon"])\n&|' modules/nixos/main.py
          grep -q flocon/configuration.nix modules/nixos/main.py && grep -q @flocon@ modules/nixos/main.py
          # Installer branding.
          cp ${./branding/logo.svg} branding/nixos/nix-snowflake.svg
          cp ${./branding/logo.png} branding/nixos/white.png
          cp ${./branding/logo.png} branding/nixos/flocon-logo.png
          cp ${./branding/slideshow.qml} branding/nixos/show.qml
          rm -r branding/nixos/gfx-landing-*.png branding/nixos/images
          sed -i 's/NixOS$/Flocon/; s/#5277C3/#0d3b66/; s/#7EBAE4/#127a8a/; s/#292F34/#FFFFFF/' branding/nixos/branding.desc
        '';
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/share/flocon
          cp ${./configuration.nix} $out/share/flocon/configuration.nix
          cp -r ${./branding} $out/share/flocon/branding
          substituteInPlace $out/lib/calamares/modules/nixos/main.py --replace-fail @flocon@ $out/share/flocon
        '';
      });
    })
  ];
}
