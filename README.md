# My dot-files

![https://builtwithnix.org](https://img.shields.io/badge/Built_With-Nix-5277C3.svg?logo=nixos&labelColor=73C3D5)

OSX configurations, expressed in [Nix](https://nixos.org/nix)

## Installation requirements

There are three requirements to be able to apply this setup:

- homebrew
- xcode developer tools
- nix
- being logged into the app store

Generate a ssh key and add it to [github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account).

```bash
ssh-keygen -t rsa -b 4096 -N '' -C "EMAIL"
```

## Installing homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew analytics off
```

[official docs](https://brew.sh)

## Installing xcode developer tools

You need git to pull this repository if you open a terminal and type `git` then
a prompt will appear asking you to install xcode developer tools.

## Install nix

Install nix using the interactive script that they provide for multi-user
installation.

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

[official docs](https://nixos.org/download.html)

## Install

Before running the install script set the hostname to one list in the `flake.nix`.

```bash
sudo scutil --set HostName lair
sudo scutil --set LocalHostName lair
sudo scutil --set ComputerName lair
dscacheutil -flushcache
./install.sh
```
