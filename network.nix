{ config, pkgs, ... }:

with pkgs;
{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = [ networkmanager_strongswan ];
    };
  };

  services.dbus.packages = [ strongswan ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 8000 ];
  };

  programs.nm-applet.enable = true;


  nixpkgs.config.packageOverrides = pkgs: {
    # strongswan = pkgs.strongswan.overrideAttrs (attrs: {
    #   buildInputs = attrs.buildInputs ++ [ pkgs.networkmanager ];
    # #   configureFlags = attrs.configureFlags ++ [ "--enable-nm" ];
    # });
    # networkmanager_strongswan = pkgs.networkmanager_strongswan.overrideAttrs (attrs: {
    #   buildInputs = attrs.buildInputs ++ [ pkgs.strongswan ];
    #   # configureFlags = [ "--with-charon=${pkgs.strongswan}/libexec/ipsec/charon-nm" ];
    # });
  };
  # services.dbus.packages = [ pkgs.strongswan ];
  # networking.networkmanager = {
  # enable = true;
  # packages = [ pkgs.networkmanager_strongswan ];
  # };

}
