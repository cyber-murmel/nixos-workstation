{ ... }:

{
  imports = [
    # ./xtrx
  ];

  hardware.rtl-sdr.enable = true;
  hardware.hackrf.enable = true;
}
