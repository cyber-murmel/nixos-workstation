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
    # zoom-us
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
  ];

  sdr-packages = with pkgs; [
    gnuradio
    sdrangel
    gqrx
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
  users.users.happy = {
    isNormalUser = true;
    description = "happy hacker";
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
    ];
  };

  home-manager.users.happy = {
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
        # vscodevim.vim
        yzhang.markdown-all-in-one
        bbenoist.nix
      ];
    };

    wayland.windowManager.sway = {
      #enable = true;
      config = {
        # keyboard/mouse/touchpad
        #input = {
        #  "*" = {
        #    xkb_layout = "de";
        #    xkb_options = "compose:caps";
        #  };
        #};

        # monitor
        output = {
          "*" = {
            background = "$HOME/wallpaper.jpg fill";
            scale = "1.0";
          };
        };

        keybindings =
          let
            mod = "Mod4";
            inherit (pkgs) brightnessctl mako playerctl ponymix wofi;
          in
          {
            "${mod}+Shift+r" = "reload";
            "${mod}+Shift+q" = "kill";
            "${mod}+Shift+e" = "exec swaynag -t warning -m 'FooBar You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

            "${mod}+Left" = "focus left";
            "${mod}+Down" = "focus down";
            "${mod}+Up" = "focus up";
            "${mod}+Right" = "focus right";

            "${mod}+Shift+Left" = "move left";
            "${mod}+Shift+Down" = "move down";
            "${mod}+Shift+Up" = "move up";
            "${mod}+Shift+Right" = "move right";

            "${mod}+v" = "split v";
            "${mod}+h" = "split h";

            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+e" = "layout toggle split";
            "${mod}+r" = "mode resize";

            "${mod}+f" = "fullscreen toggle";
            "${mod}+Shift+space" = "floating toggle";

            "${mod}+1" = "workspace 1";
            "${mod}+2" = "workspace 2";
            "${mod}+3" = "workspace 3";
            "${mod}+4" = "workspace 4";
            "${mod}+5" = "workspace 5";
            "${mod}+6" = "workspace 6";
            "${mod}+7" = "workspace 7";
            "${mod}+8" = "workspace 8";
            "${mod}+9" = "workspace 9";
            "${mod}+0" = "workspace 10";

            "${mod}+Shift+1" = "move container to workspace 1";
            "${mod}+Shift+2" = "move container to workspace 2";
            "${mod}+Shift+3" = "move container to workspace 3";
            "${mod}+Shift+4" = "move container to workspace 4";
            "${mod}+Shift+5" = "move container to workspace 5";
            "${mod}+Shift+6" = "move container to workspace 6";
            "${mod}+Shift+7" = "move container to workspace 7";
            "${mod}+Shift+8" = "move container to workspace 8";
            "${mod}+Shift+9" = "move container to workspace 9";
            "${mod}+Shift+0" = "move container to workspace 10";

            "${mod}+Return" = "exec foot";
            "${mod}+Shift+Return" = "exec firefox";
            "${mod}+Space" = "exec ${mako}/bin/makoctl dismiss";
            "${mod}+d" = "exec ${wofi}/bin/wofi --show drun";

            # brightness
            XF86MonBrightnessDown = "exec ${brightnessctl}/bin/brightnessctl -q s 5%-";
            XF86MonBrightnessUp = "exec ${brightnessctl}/bin/brightnessctl -q s 5%+";

            # volume
            XF86AudioRaiseVolume = "exec ${ponymix}/bin/ponymix increase 5";
            XF86AudioLowerVolume = "exec ${ponymix}/bin/ponymix decrease 5";
            XF86AudioMute = "exec ${ponymix}/bin/ponymix toggle";

            # media
            XF86AudioPlay = "exec ${playerctl}/bin/playerctl play-pause";
            XF86AudioPause = "exec ${playerctl}/bin/playerctl pause";
            XF86AudioNext = "exec ${playerctl}/bin/playerctl next";
            XF86AudioPrev = "exec ${playerctl}/bin/playerctl previous";
          };

        # allow toggling between workspaces
        workspaceAutoBackAndForth = true;

        # enable gaps between windows
        gaps = {
          inner = 12;
        };

        # # application/window specific settings
        # window = {
        #   commands = let
        #     inhibitFullScreenIdle = criteria: {
        #       inherit criteria;
        #       command = "inhibit_idle fullscreen";
        #     };
        #   in
        #   # prevent screen blanking for these apps
        #   (map inhibitFullScreenIdle [ {
        #     class = "mpv";
        #   } {
        #     app_id = "firefox";
        #   }]);
        # };
      };
    };
  };
}
