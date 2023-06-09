{
  description = "Ellies's darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR";
    devenv.url = "github:cachix/devenv/latest";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs, home-manager, nur, ... }@inputs: {
    devShells = import ./dev_shells inputs;
    darwinConfigurations = {

      "lair" = let
        system = "x86_64-darwin";
        devenv = inputs.devenv.packages.${system}.devenv;
        hostname = "lair";
        common = [
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ nur.overlay ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.ellie = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit devenv; };
          }
        ];
      in darwin.lib.darwinSystem rec {
        inherit system;
        modules = common ++ [ ./darwin-configuration.nix ]
          ++ [ ({ pkgs, config, ... }: { networking.hostName = "lair"; }) ];
      };

      # Building the flakes require root privileges to update the HOSTNAME
      # and then be able to nix build ".#HOSTNAME"
      # TODO build the flake also for nixos
    };
  };
}
