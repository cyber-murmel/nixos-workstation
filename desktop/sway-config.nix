{ config, pkgs, lib, ... }:

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

''
  # Default config for sway
  #
  # Copy this to ~/.config/sway/config and edit it to your liking.
  #
  # Read `man 5 sway` for a complete reference.

  ### Variables
  #
  # Logo key. Use Mod1 for Alt.
  set $mod Mod4
  # Home row direction keys, like vim
  set $left h
  set $down j
  set $up k
  set $right l
  # Your preferred terminal emulator
  set $term ${alacritty}/bin/alacritty
  # Your preferred application launcher
  # Note: pass the final command to swaymsg so that the resulting window can be opened
  # on the original workspace that the command was run on.
  set $menu ${wofi}/bin/wofi --show run | xargs swaymsg exec --

  set $lock ${swaylock}/bin/swaylock --show-failed-attempts --indicator-caps-lock --color 000000

  ### Output configuration
  #
  # Default wallpaper (more resolutions are available in @datadir@/backgrounds/sway/)
  #output * bg @datadir@/backgrounds/sway/Sway_Wallpaper_Blue_1920x1080.png fill
  #
  # Example configuration:
  #
  #   output HDMI-A-1 resolution 1920x1080 position 1920,0
  #
  # You can get the names of your outputs by running: swaymsg -t get_outputs

  ### Idle configuration
  #
  # Example configuration:
  #
  exec ${swayidle}/bin/swayidle -w \
           timeout 300 '${swaylock}/bin/swaylock -f -c 000000' \
           timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
           before-sleep '${swaylock}/bin/swaylock -f -c 000000'
  #
  # This will lock your screen after 300 seconds of inactivity, then turn off
  # your displays after another 300 seconds, and turn your screens back on when
  # resumed. It will also lock your screen before your computer goes to sleep.

  ### Input configuration
  #
  # Example configuration:
  #
  #   input "2:14:SynPS/2_Synaptics_TouchPad" {
  #       dwt enabled
  #       tap enabled
  #       natural_scroll enabled
  #       middle_emulation enabled
  #   }
  #
  # You can get the names of your inputs by running: swaymsg -t get_inputs
  # Read `man 5 sway-input` for more information about this section.

  input * {
      xkb_layout "us"
      xkb_variant "altgr-intl"
      tap enable
  }

  ### Key bindings
  #
  # Basics:
  #
      # Start a terminal
      bindsym $mod+Return exec $term

      # Kill focused window
      bindsym $mod+Shift+q kill

      # Start your launcher
      bindsym $mod+d exec $menu

      # Start your launcher
      bindsym $mod+Shift+s exec $lock

      # Drag floating windows by holding down $mod and left mouse button.
      # Resize them with right mouse button + $mod.
      # Despite the name, also works for non-floating windows.
      # Change normal to inverse to use left mouse button for resizing and right
      # mouse button for dragging.
      floating_modifier $mod normal

      # Reload the configuration file
      bindsym $mod+Shift+c reload

      # Exit sway (logs you out of your Wayland session)
      bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
  #
  # Moving around:
  #
      # Move your focus around
      bindsym $mod+$left focus left
      bindsym $mod+$down focus down
      bindsym $mod+$up focus up
      bindsym $mod+$right focus right
      # Or use $mod+[up|down|left|right]
      bindsym $mod+Left focus left
      bindsym $mod+Down focus down
      bindsym $mod+Up focus up
      bindsym $mod+Right focus right

      # Move the focused window with the same, but add Shift
      bindsym $mod+Shift+$left move left
      bindsym $mod+Shift+$down move down
      bindsym $mod+Shift+$up move up
      bindsym $mod+Shift+$right move right
      # Ditto, with arrow keys
      bindsym $mod+Shift+Left move left
      bindsym $mod+Shift+Down move down
      bindsym $mod+Shift+Up move up
      bindsym $mod+Shift+Right move right
  #
  # Workspaces:
  #
      # Switch to workspace
      bindsym $mod+1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+7 workspace number 7
      bindsym $mod+8 workspace number 8
      bindsym $mod+9 workspace number 9
      bindsym $mod+0 workspace number 10
      # Move focused container to workspace
      bindsym $mod+Shift+1 move container to workspace number 1
      bindsym $mod+Shift+2 move container to workspace number 2
      bindsym $mod+Shift+3 move container to workspace number 3
      bindsym $mod+Shift+4 move container to workspace number 4
      bindsym $mod+Shift+5 move container to workspace number 5
      bindsym $mod+Shift+6 move container to workspace number 6
      bindsym $mod+Shift+7 move container to workspace number 7
      bindsym $mod+Shift+8 move container to workspace number 8
      bindsym $mod+Shift+9 move container to workspace number 9
      bindsym $mod+Shift+0 move container to workspace number 10
      # Note: workspaces can have any name you want, not just numbers.
      # We just use 1-10 as the default.
  #
  # Layout stuff:
  #
      # You can "split" the current object of your focus with
      # $mod+b or $mod+v, for horizontal and vertical splits
      # respectively.
      bindsym $mod+b splith
      bindsym $mod+v splitv

      # Switch the current container between different layout styles
      bindsym $mod+s layout stacking
      bindsym $mod+w layout tabbed
      bindsym $mod+e layout toggle split

      # Make the current focus fullscreen
      bindsym $mod+f fullscreen

      # Toggle the current focus between tiling and floating mode
      bindsym $mod+Shift+space floating toggle

      # Swap focus between the tiling area and the floating area
      bindsym $mod+space focus mode_toggle

      # Move focus to the parent container
      bindsym $mod+a focus parent
  #
  # Scratchpad:
  #
      # Sway has a "scratchpad", which is a bag of holding for windows.
      # You can send windows there and get them back later.

      # Move the currently focused window to the scratchpad
      bindsym $mod+Shift+minus move scratchpad

      # Show the next scratchpad window or hide the focused scratchpad window.
      # If there are multiple scratchpad windows, this command cycles through them.
      bindsym $mod+minus scratchpad show
  #
  # Resizing containers:
  #
  mode "resize" {
      # left will shrink the containers width
      # right will grow the containers width
      # up will shrink the containers height
      # down will grow the containers height
      bindsym $left resize shrink width 10px
      bindsym $down resize grow height 10px
      bindsym $up resize shrink height 10px
      bindsym $right resize grow width 10px

      # Ditto, with arrow keys
      bindsym Left resize shrink width 10px
      bindsym Down resize grow height 10px
      bindsym Up resize shrink height 10px
      bindsym Right resize grow width 10px

      # Return to default mode
      bindsym Return mode "default"
      bindsym Escape mode "default"
  }
  bindsym $mod+r mode "resize"

  #
  # Volume Control:
  #

  bindsym XF86AudioRaiseVolume exec ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%
  bindsym XF86AudioLowerVolume exec ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%
  bindsym XF86AudioMute exec ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle
  bindsym XF86AudioMicMute exec ${pulseaudio}/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle

  bindsym --locked XF86MonBrightnessUp exec light -S "$(light -G | awk '{ print int(($1 + .72) * 1.4) }')"
  bindsym --locked XF86MonBrightnessDown exec light -S "$(light -G | awk '{ print int($1 / 1.4) }')"

  bindsym XF86TouchpadToggle input type:touchpad events toggle enabled disabled

  bindsym Print exec ${grim}/bin/grim -g "$(${slurp}/bin/slurp -d)" - | ${wl-clipboard}/bin/wl-copy -t image/png

  #
  # Status Bar:
  #
  exec_always ${waybar}/bin/waybar

  # # Read `man 5 sway-bar` for more information about this section.
  # bar {
  #     position top
  # 
  #     # When the status_command prints a new line to stdout, swaybar updates.
  #     # The default just shows the current date and time.
  #     status_command while date +'%Y-%m-%d %l:%M:%S %p'; do sleep 1; done
  # 
  #     colors {
  #         statusline #ffffff
  #         background #323232
  #         inactive_workspace #32323200 #32323200 #5c5c5c
  #     }
  # }

  bindsym $mod+period exec ${mako}/bin/makoctl dismiss -a

  #
  # Bluetooth Applet:
  #
  exec_always ${blueman}/bin/blueman-applet

  #
  # NetworkManager Applet:
  #
  exec_always ${networkmanagerapplet}/bin/nm-applet --indicator

  exec ${dbus-sway-environment}/bin/dbus-sway-environment
  exec ${configure-gtk}/bin/configure-gtk
  exec ${wmname}/bin/wmname LG3D

  # give sway a little time to startup before starting kanshi.
  #exec sleep 5; systemctl --user start kanshi.service

  for_window [app_id="pinentry-qt"] floating enable
  for_window [title="Extension: (PassFF) - — Mozilla Firefox"] floating enable

  exec systemctl --user import-environment SWAYSOCK WAYLAND_DISPLAY

  include @sysconfdir@/sway/config.d/*
''
