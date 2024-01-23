{ pkgs, ... }:

with pkgs;
rec {
  enable = true;
  systemd.enable = true;

  # extraConfigEarly = ''
  # '';

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