{
  pkgs,
  lib,
  writeShellScriptBin,
  nodejs,
  ...
}:
let
  inherit (pkgs)
    writeShellScriptBin
    nodejs
    ;
  claudeCode = pkgs.writeShellScriptBin "claude" ''
    # Set up npm global prefix to avoid permission issues  
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
    
    # Create npm global directory if it doesn't exist
    mkdir -p "$NPM_CONFIG_PREFIX"
    
    # Check if claude is installed and working
    if ! "$NPM_CONFIG_PREFIX/bin/claude" --version &> /dev/null; then
      echo "Installing @anthropic-ai/claude-code..."
      ${pkgs.nodejs}/bin/npm install -g @anthropic-ai/claude-code
      
      # Verify installation
      if ! "$NPM_CONFIG_PREFIX/bin/claude" --version &> /dev/null; then
        echo "Installation failed or claude binary not found at expected location."
        echo "Trying to find claude binary..."
        
        # Try to find where npm actually installed it
        CLAUDE_PATH=$(find "$NPM_CONFIG_PREFIX" -name "claude" -type f -executable 2>/dev/null | head -1)
        
        if [ -n "$CLAUDE_PATH" ]; then
          echo "Found claude at: $CLAUDE_PATH"
          exec "$CLAUDE_PATH" "$@"
        else
          echo "Could not find claude binary. Trying npx as fallback..."
          exec ${pkgs.nodejs}/bin/npx @anthropic-ai/claude-code "$@"
        fi
      fi
    fi
    
    # Run claude command
    exec "$NPM_CONFIG_PREFIX/bin/claude" "$@"
  '';
in
{
  #  TODO REVIEW ALL THESE PACKAGES
  # check https://github.com/jmackie/dotfiles/blob/main/modules/tools/default.nix
  home.packages = (with pkgs; [
    devenv
    claudeCode
    neovim-remote
    nerd-fonts.iosevka
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
    beamPackages.elixir
    terraform
    ngrok
    imagemagick
    jpegoptim
    postgresql
    awscli2
    ssm-session-manager-plugin
    redis
    nodejs
    git-crypt


    # lsp
    elixir-ls
    erlang-language-platform
    terraform-ls
    #rnix-lsp
    dockerfile-language-server
    #nodePackages.vim-language-server
    bash-language-server
    yaml-language-server
    #  todo Json ls and tailwindcss

    #linting
    rust-analyzer
    rustfmt
    hadolint
    nixfmt
    tflint
    # nodePackages.textlint
    prettier
    markdownlint-cli
    erlfmt
    shellcheck

  ]);

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.gpg.enable = true;
  programs.neovim = {
    enable = true;
    withRuby = true;
    withPython3 = true;
  };

  # MAYBE MOVE TO SHELL/TERMINAL module
  programs.lsd = {
    enable = true;
  };
}
