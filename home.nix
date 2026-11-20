{ config, pkgs, lib, ... }: {

  programs.home-manager.enable = true;
  home.stateVersion = "23.05";

  imports = [
    ./modules/claude
    ./modules/gh
    ./modules/git
    ./modules/zsh
    ./modules/tools
  ];
}
