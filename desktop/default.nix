{ config, pkgs, ... }:

let
  euro-plate = with pkgs; stdenv.mkDerivation rec {
    name = "EuroPlate";
    version = "0";
    src = fetchurl {
      url = "https://www.autokennzeichen.info/files/EuroPlate.ttf";
      sha256 = "sha256-49b6rfEKmt9IipElRENBtaIq2E1XVnu2smK+pyAilCI=";
      curlOptsList = [ "-H" "User-Agent: Mozilla/5.0" ];
    };
    phases = [ "buildPhase" ];

    buildCommand = ''
      cp $src ${name}.ttf
      install -m444 -Dt $out/share/fonts/truetype ${name}.ttf
    '';
  };
in

{
  imports = [
    ./theme.nix
    ./gtx3050ti.nix
    ./sway.nix
    # ./plasma.nix
    ./v4l2.nix
  ];

  # boot.extraModulePackages = with config.boot.kernelPackages; [ intel_pstate ];

  services = {
    xserver = {
      enable = true;
      displayManager.sddm = {
        enable = true;
        settings = {
          General = {
            DisplayServer = "wayland";
          };
        };
      };
    };

    # greetd = {
    #   enable = true;
    #   settings = {
    #     default_session = {
    #       command = "${pkgs.sway}/bin/sway --unsupported-gpu";
    #     };
    #   };
    # };

    # iOS
    usbmuxd.enable = true;

    # Android MTP
    gvfs.enable = true;

    avahi = {
      enable = true;
      nssmdns = true;
    };
  };

  programs = {
    steam = {
      enable = true;
      # https://github.com/NixOS/nixpkgs/issues/271483
      # package = (pkgs.steam.override { extraLibraries = pkgs: [ pkgs.gperftools ]; });
    };
    gnupg.agent = {
      enable = true;
      pinentryFlavor = "qt";
      #   enableSSHSupport = true;
    };
  };

  hardware.opengl.driSupport32Bit = true; # Enables support for 32bit libs that steam uses

  environment.wordlist.enable = true;

  fonts.packages = with pkgs;
    [
      fantasque-sans-mono
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      dejavu_fonts
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      aileron
      euro-plate
    ];

  gtk.iconCache.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
  '';
}
