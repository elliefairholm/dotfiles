{ config, pkgs, lib, devenv, ... }: {

  programs.home-manager.enable = true;
  home.stateVersion = "23.05";

  imports = [
    ./modules/gh
    ./modules/git
    ./modules/zsh
    ./modules/tools
  ];
}
