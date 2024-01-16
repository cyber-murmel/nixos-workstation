{ config, pkgs, lib, ... }:

let
  pwmanager-packages = with pkgs; [
    (pass.withExtensions (ext: with ext; [
      # pass-audit
      pass-otp
      # pass-import
      pass-genphrase
      pass-update
      pass-tomb
    ]))
    qtpass
    pinentry-qt
    rofi-pass
  ];

  cad-packages = with pkgs; [
    solvespace
    openscad
    super-slicer
    kicad
    libxslt
    rink
  ];

  chat-packages = with pkgs; [
    signal-desktop
    element-desktop
    tdesktop
    discord
    # skypeforlinux
    zoom-us
    # teams
    (mumble.override { pulseSupport = true; })
    slack-dark
  ];

  development-packages = with pkgs; [
    git
    git-cola
    gist
    vim
    python3
    nixpkgs-fmt
    gnumake
    cmake
    gcc
    gcc-arm-embedded
    # clang
    openocd
    stlink
    stm32flash
    octaveFull
    ghostscript
    ghidra
    cargo-watch

    virt-manager
  ];

  roblox = with pkgs; writeScriptBin "roblox" ''
    #! ${bash}/bin/bash

    set -euo pipefail

    ${grapejuice}/bin/grapejuice app
  '';
  game-packages = with pkgs; [
    #(polymc.override { msaClientID = "5aa5229c-6491-4d81-96df-6c22bab973e4"; })
    the-powder-toy
    grapejuice
    roblox
  ];

  office-packages = with pkgs; [
    simple-scan
    brscan4
    thunderbird
    libreoffice
    kate
    evince
    gnome.eog
    gimp
    megacmd
    inkscape
  ];

  sdr-packages = with pkgs; [
    (gnuradio3_8.override {
      extraPackages = with gnuradio3_8Packages; [
        osmosdr
        limesdr
        # python
        grnet
        rds
      ];
    })
    sdrangel
    gqrx
    inspectrum
    urh
  ];

  video-packages = with pkgs; [
    vlc
    obs-studio
    obs-studio-plugins.wlrobs
    ffmpeg-full
    imagemagick
    yt-dlp
  ];

  txtlock = with pkgs; writeScriptBin "txtlock" ''
    #! ${bash}/bin/bash

    image=$(mktemp --suffix=.png)
    text="$@"
    ${imagemagick}/bin/convert -size 1920x1080 xc:black -font "Fantasque-Sans-Mono-Bold" -pointsize 128 -fill grey -gravity center -annotate +0+0 "$text" $image
    ${swaylock}/bin/swaylock --show-failed-attempts --indicator-caps-lock --image $image
    rm $image
  '';
  sway-packages = with pkgs; [
    alacritty # gpu accelerated terminal
    glib # gsettings
    txtlock
    dracula-theme # gtk theme
    gnome3.adwaita-icon-theme # default gnome cursors
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    wdisplays
    pcmanfm
  ];
in
{
  users.users.marble = {
    isNormalUser = true;
    description = "marble";
    extraGroups = [
      "wheel"
      "networkmanager"
      "plugdev"
      "dialout"
      "libusb"
      "scanner"
      "lp"
      "docker"
      "cdrom"
      "video"
      "libvirtd"
      "adbuser"
      "usb"
    ];
  };

  home-manager.users.marble = {
    nixpkgs.config.allowUnfree = true;
    home = {
      # sessionVariables = {
      #   XDG_CURRENT_DESKTOP = "sway";
      #   XDG_SESSION_TYPE = "wayland";
      #   _JAVA_AWT_WM_NONREPARENTING = "1";
      # };

      packages = with pkgs; [
        (firefox-wayland.override {
          nativeMessagingHosts = [ passff-host ];
        })

        # (firefox.override {
        #   extraNativeMessagingHosts = [ passff-host ];
        # })

        pavucontrol

        htop
        bottom
        file
        xdg-utils

        unzip
        p7zip

        # iOS
        libimobiledevice
        ifuse

        curl
        wget
        networkmanagerapplet
        ipcalc
        nettools
        iproute2
        arp-scan
        ipv6calc
        nmap
        macchanger
        sshfs
        (writeShellScriptBin "mac2v6ll" ''
          ipv6calc --action prefixmac2ipv6 --in prefix+mac --out ipv6addr fe80:: $@
        '')

        python3Packages.qrcode

        termtosvg
      ] ++ pwmanager-packages
      ++ cad-packages
      ++ chat-packages
      ++ development-packages
      ++ game-packages
      ++ office-packages
      ++ sdr-packages
      ++ video-packages
      ++ sway-packages;

      stateVersion = config.system.stateVersion;
    };

    programs.vscode = {
      enable = true;
      # package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        yzhang.markdown-all-in-one
        bbenoist.nix
        github.copilot
        eamodio.gitlens
        antyos.openscad
        ms-python.python
        ms-vsliveshare.vsliveshare
        ms-vscode.cmake-tools
        twxs.cmake
        ms-vscode.makefile-tools
        ms-vscode.cpptools
      ];
    };

    wayland.windowManager.sway = import ./sway-config.nix { inherit pkgs; };
  };
}
