{ pkgs, ... }:

{
  hardware = {
    # Scanners
    sane = {
      enable = true;
      brscan4 = {
        enable = true;
        netDevices = {
          home = { model = "MFC-9142CDN"; ip = "10.0.0.79"; };
          office = { model = "MFC-L2710DW"; ip = "10.0.0.190"; };
        };
      };
    };
  };
}

