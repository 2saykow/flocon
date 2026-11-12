{
  description = "Flocon — un OS basé sur NixOS avec le bureau Cinnamon";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      mk = extra: nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./configuration.nix ] ++ extra;
      };
    in
    {
      # VM de test : utilisateur « flocon », connecté automatiquement.
      nixosConfigurations.flocon-vm = mk [{
        users.users.flocon = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" ];
          initialPassword = "flocon"; # VM de test uniquement
        };
        services.displayManager.autoLogin = { enable = true; user = "flocon"; };
        virtualisation.vmVariant.virtualisation = { memorySize = 4096; cores = 4; };
      }];

      # ISO live amorçable sur une vraie machine, avec l'installateur graphique.
      nixosConfigurations.flocon-iso = mk [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares.nix"
        ./installer.nix
      ];

      packages.${system} = {
        vm = self.nixosConfigurations.flocon-vm.config.system.build.vm;
        iso = self.nixosConfigurations.flocon-iso.config.system.build.isoImage;
      };
    };
}
