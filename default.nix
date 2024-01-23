{ config, pkgs, lib, ... }:
let
  nixpkgs_version = "${lib.versions.major lib.version}.${lib.versions.minor lib.version}";
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${nixpkgs_version}.tar.gz";
in
{
  imports = [
    # requires `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager` to work
    # <home-manager/nixos>
    (import "${home-manager}/nixos")
    ./desktop
    ./users
    ./audio.nix
    ./bluetooth.nix
    ./locale.nix
    ./libvirt.nix
    ./network.nix
    ./printing.nix
    ./scanners.nix
    ./sdr.nix
    ./emulation.nix
  ];

  security.polkit.enable = true;

  nixpkgs.config.allowUnfree = true;

  programs.java.enable = true;

  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
}
