{ pkgs, devenv, ... }: {
  #  TODO REVIEW ALL THESE PACKAGES
  # check https://github.com/jmackie/dotfiles/blob/main/modules/tools/default.nix
  home.packages = [ devenv ] ++ (with pkgs; [
    neovim-remote
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
    unixtools.watch
    fortune
    fd
    jq
    yq
    btop
    ripgrep
    cloc
    wget
    tig
    tree
    peco
    elixir_1_16
    ngrok
    imagemagick
    jpegoptim

    # lsp
    elixir_ls
    erlang-ls
    terraform-ls
    #rnix-lsp
    nodePackages.dockerfile-language-server-nodejs
    #nodePackages.vim-language-server
    nodePackages.bash-language-server
    nodePackages.yaml-language-server
    #  todo Json ls and tailwindcss

    #linting
    rust-analyzer
    rustfmt
    hadolint
    nixfmt-classic
    tflint
    # nodePackages.textlint
    nodePackages.prettier
    nodePackages.markdownlint-cli
    erlfmt
    shellcheck

  ]);

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.gpg.enable = true;
  programs.neovim.enable = true;

  # MAYBE MOVE TO SHELL/TERMINAL module
  programs.lsd = {
    enable = true;
    enableAliases = true;
  };
}
