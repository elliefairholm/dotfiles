{ config, lib, pkgs, ... }:

{
  system.stateVersion = 5;
#  ids.gids.nixbld = 30000;
#  ids.uids.nixbld = 350;
  environment.shells = [ pkgs.zsh ];
  # https://github.com/LnL7/nix-darwin/issues/165
  environment.etc = {
    "sudoers.d/10-nix-commands".text = ''
      %admin ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild, \
                                     /run/current-system/sw/bin/nix*, \
                                     /run/current-system/sw/bin/ln, \
                                     /nix/store/*/activate, \
                                     /bin/launchctl
    '';
  };

  users = {
    users = {
      elliefairholm = {
        home = "/Users/elliefairholm";
        shell = pkgs.zsh;
      };
    };
  };

  programs.bash.enable = false;
  programs.nix-index.enable = true;
  programs.zsh.enable = true;

  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "Iosevka" ]; }) ];

  nix = {
    #configureBuildUsers = true;
    settings = { trusted-users = [ "root" "elliefairholm" ]; };
    package = pkgs.nixVersions.git;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  #ids.uids.nixbld = lib.mkForce 30000;

  nixpkgs.config.allowUnfree = true;

  ############
  #  System  #
  ############

  time.timeZone = "Europe/London";

  system = {
    activationScripts.postActivation.text = ''
      # Shows battery percentage
      defaults write com.apple.menuextra.battery ShowPercent YES; killall SystemUIServer
    '';
    defaults = {
      NSGlobalDomain = {
        "com.apple.mouse.tapBehavior" = 1;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = true;
      };

      # maybe desktop instead?
      screencapture.location = "/tmp";

      dock = {
        autohide = true;
        mru-spaces = false;
        orientation = "bottom";
        showhidden = true;
        static-only = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = false;
      };
    };

    keyboard = { enableKeyMapping = true; };
  };

  ############
  # SERVICES #
  ############

  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./conf.d/skhd.conf;
  };

  services.nix-daemon.enable = true;

  ############
  # Homebrew #
  ############

  homebrew = {
    enable = true;
    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
    };

    global = {
      autoUpdate = true;
      brewfile = true;
      lockfiles = true;
    };

    # taps = [ "homebrew/core" "homebrew/cask" ];
    brews = [ 
      "mas"
      # "asciinema"
      # "exercism"
    ];

    casks = [
      "chromium"
      "google-drive"
      "now-tv-player"
      "google-chrome"
      "adobe-acrobat-reader"
      "1password"
      "docker"
      "spotify"
      "windsurf"
      "insomnia"
    ];

    masApps = {
     # "Numbers" = 409203825;
     # Amphetamine = 937984704;
     # Pages = 409201541;
     # Keynote = 409183694;
    #  Magnet = 441258766;
    #  "TickTick:To-Do List, Calendar" = 966085870;
    };
  };

  environment.variables.LANG = "en_GB.UTF-8";
  environment.loginShell = "${pkgs.zsh}/bin/zsh -l";
  services.activate-system.enable = true;
}
