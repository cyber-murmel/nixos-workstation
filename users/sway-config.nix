{ pkgs, ... }:
let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts  
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    text = ''
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
      systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
    '';
  };

  # currently, there is some friction between sway and gtk:
  # https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
  # the suggested way to set gtk settings is with gsettings
  # for gsettings to work, we need to tell it where the schemas are
  # using the XDG_DATA_DIR environment variable
  # run at the end of sway config
  configure-gtk = pkgs.writeTextFile {
    name = "configure-gtk";
    destination = "/bin/configure-gtk";
    executable = true;
    text =
      let
        schema = pkgs.gsettings-desktop-schemas;
        datadir = "${schema}/share/gsettings-schemas/${schema.name}";
      in
      ''
        export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
        gnome_schema=org.gnome.desktop.interface
        gsettings set $gnome_schema gtk-theme 'Dracula'
      '';
  };
in
with pkgs;
rec {
  enable = true;
  extraConfigEarly = ''
  '';
  config = rec {
    # terminal = "${alacritty}/bin/alacritty";
    menu = "${wofi}/bin/wofi --show run | xargs swaymsg exec --";
    modifier = "Mod4";
    # keyboard/mouse/touchpad
    input = {
     "*" = {
       xkb_layout = "us";
       xkb_variant = "altgr-intl";
       tap = "enable";
     };
    };

    # # monitor
    # output = {
    #   "*" = {
    #     background = "$HOME/wallpaper.jpg fill";
    #     scale = "1.0";
    #   };
    # };

    keybindings = lib.mkOptionDefault {
      "${modifier}+0" = "workspace number 10";
      "${modifier}+Shift+0" = "move container to workspace number 10";

      "${modifier}+Shift+s" = "exec ${swaylock}/bin/swaylock --show-failed-attempts --indicator-caps-lock --color 000000";

      "${modifier}+Period" = "exec ${mako}/bin/makoctl dismiss -a";

      "XF86AudioRaiseVolume" = "exec ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
      "XF86AudioLowerVolume" = "exec ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
      "XF86AudioMute" = "exec ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
      "XF86AudioMicMute" = "exec ${pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle";
      
      "XF86MonBrightnessUp" = "exec ${light}/bin/light -S \"$(${light}/bin/light -G | awk '{ print int(($1 + .72) * 1.4) }')\"";
      "XF86MonBrightnessDown" = "exec ${light}/bin/light -S \"$(${light}/bin/light -G | awk '{ print int($1 / 1.4) }')\"";

      "Print" = "exec ${grim}/bin/grim -g \"$(${slurp}/bin/slurp -d)\" - | ${wl-clipboard}/bin/wl-copy -t image/png";
    };

    # allow toggling between workspaces
    workspaceAutoBackAndForth = true;

    # disable sway-bar
    bars = [];

    startup = [
      {
        command = "${waybar}/bin/waybar";
        # always = true;
      }
      {
        command = "${blueman}/bin/blueman-applet";
        # always = true;
      }
      {
        command = "${networkmanagerapplet}/bin/nm-applet --indicator";
        # always = true;
      }
      {
        # This will lock the screen after 300 seconds of inactivity, then turn off
        # the displays after another 300 seconds, and turn the screens back on when
        # resumed. It will also lock the screen before the computer goes to sleep.
        command = ''
          {swayidle}/bin/swayidle -w \
             timeout 300 '${swaylock}/bin/swaylock -f -c 000000' \
             timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
             before-sleep '${swaylock}/bin/swaylock -f -c 000000'
        '';
        # always = true;
      }
      {command = "${dbus-sway-environment}/bin/dbus-sway-environment";}
      {command = "${configure-gtk}/bin/configure-gtk";}
      {command = "${wmname}/bin/wmname LG3D";}
      {command = "systemctl --user import-environment SWAYSOCK WAYLAND_DISPLAY";}
    ];

    floating.criteria = [
      {
        app_id = "pinentry-qt";
      }
      {
        title = "Extension: (PassFF) - — Mozilla Firefox";
      }
    ];
  };
  extraOptions = [
    "--unsupported-gpu"
  ];
}