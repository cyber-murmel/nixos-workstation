{ pkgs, lib, ... }:

let
  dark = true;
  gtkThemeName = "Adwaita" + (if dark then "-dark" else "");
  qt5Style = "adwaita" + (if dark then "-dark" else "");
in
{
  environment = {
    variables = {
      GTK_THEME = "Adwaita:dark";
    };

    etc = {
      "xdg/gtk-2.0/gtkrc".text = ''
        gtk-theme-name = "${gtkThemeName}"
        gtk-icon-theme-name = "Adwaita"
      '';
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name = "${gtkThemeName}"
        gtk-application-prefer-dark-theme = ${if dark then "true" else "false"}
        gtk-icon-theme-name = Adwaita
      '';
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "${qt5Style}";
  };

  gtk.iconCache.enable = true;
}
