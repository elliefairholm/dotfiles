{
  description = "Ellie's darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    # devenv is pinned (not tracking `latest`) because its current `latest`
    # bundles a nixd nightly that fails to build, and it follows its own pinned
    # nixpkgs rather than our top-level one because it's version-sensitive: this
    # devenv rev needs darwin.apple_sdk_11_0, which newer nixpkgs removed. This
    # pin matches the combo the live system was built with. Revisit once devenv
    # `latest` builds cleanly against current nixpkgs.
    nixpkgs-devenv.url = "github:nixos/nixpkgs/b7ba7f9f45c5cd0d8625e9e217c28f8eb6a19a76";
    devenv.url = "github:cachix/devenv/98b99188b1539c0d2a45e0a0a161a7b8e797caac";
    devenv.inputs.nixpkgs.follows = "nixpkgs-devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw="
    #  "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    #  "pepo.cachix.org-1:8sELuSHMV0vqHtuvnzKh3DCzb/+u+PtCY4Gl6V2blCg="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
    #  "https://nixpkgs-terraform.cachix.org"
    #  "https://pepo.cachix.org"
    ];
  };

  outputs = { self, darwin, nixpkgs, home-manager, nur, ... }@inputs: {
    # devShells = import ./dev_shells inputs;
    darwinConfigurations = {

      "bosque" = let
        system = "aarch64-darwin";
        devenv = inputs.devenv.packages.${system}.devenv;
        hostname = "bosque";
        common = [
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [ nur.overlays.default ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.elliefairholm = import ./home.nix;
            home-manager.extraSpecialArgs = { inherit devenv; };
          }
        ];
      in darwin.lib.darwinSystem rec {
        inherit system;
        modules = common ++ [ ./darwin-configuration.nix ]
          ++ [ ({ pkgs, config, ... }: { networking.hostName = "bosque"; }) ];
      };

      # Building the flakes require root privileges to update the HOSTNAME
      # and then be able to nix build ".#HOSTNAME"
      # TODO build the flake also for nixos
    };
  };
}
