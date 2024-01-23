{ config, pkgs, lib, ... }:
{
  imports = [
    ./marble.nix
    ./happy.nix
  ];

  programs.zsh = {
    enable = true;
    # interactiveShellInit = ''
    #   source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    # '';
    # promptInit = ""; # otherwise it'll override the grml prompt
    # histSize = 1000000;
  };

  users = {
    defaultUserShell = pkgs.zsh;
    extraGroups = {
      plugdev = { };
      usb = { };
    };
  };

  # services.gnome.gnome-keyring.enable = true;

  services.udev = {
    packages = with pkgs; [
      openocd
      logitech-udev-rules
    ];
    extraRules = ''
      # apollo
      ATTR{idVendor}=="1d50", ATTR{idProduct}=="615c", MODE="664", GROUP="plugdev"
      # bmp
      ATTR{idVendor}=="1d50", ATTR{idProduct}=="6017", MODE="664", GROUP="plugdev"
      ATTR{idVendor}=="1d50", ATTR{idProduct}=="6018", MODE="664", GROUP="plugdev"
      # USBasp
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="plugdev", MODE="0666"
      # micronucleus
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="0753", GROUP="plugdev", MODE="0666"
      # DigiCDC
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16d0", ATTRS{idProduct}=="087e", GROUP="plugdev", MODE="0666"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="048d", ATTRS{idProduct}=="ce00", GROUP="plugdev", MODE:="0660"

      # Saleae Logic
      ATTRS{idVendor}=="0925", ATTRS{idProduct}=="3881", ENV{ID_SIGROK}="1"
      # Cypress FX2
      ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="8613", ENV{ID_SIGROK}="1"

      # Grant access permissions to users who are in the "plugdev" group.
      ENV{ID_SIGROK}=="1", MODE="660", GROUP="plugdev"

      # Kingst Virtual Instruments
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a1", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a2", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a3", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="01a4", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="02a1", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="02a2", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="02a3", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="03a1", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="03a2", GROUP="plugdev", MODE="0660"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="77a1", ATTR{idProduct}=="03a3", GROUP="plugdev", MODE="0660"

      # xtrx
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0525", ATTRS{idProduct}=="3380", GROUP="plugdev", MODE="0666"

      # MCH2020 Badge
      SUBSYSTEM=="usb", ATTR{idVendor}=="16d0", ATTR{idProduct}=="0f9a", MODE="0666"

      # FLIR Systems FLIR ONE Camera
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="09cb", ATTR{idProduct}=="1996", GROUP="plugdev", MODE="0660"
    '';
  };
}
