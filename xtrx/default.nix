{ pkgs, config, ... }:

with pkgs;
let
  libusb3380 = callPackage ./libusb3380 { };
  libxtrxll = callPackage ./libxtrxll { inherit libusb3380; };
  libxtrxdsp = callPackage ./libxtrxdsp { };
  liblms7002m = callPackage ./liblms7002m { };
  libxtrx = callPackage ./libxtrx { inherit libxtrxll libxtrxdsp liblms7002m; };

  xtrx_linux_pcie_drv = callPackage ./xtrx_linux_pcie_drv {
    kernel = config.boot.kernelPackages.kernel;
  };

  soapysdr_with_xtrx = soapysdr.override {
    extraPackages = [
      #limesuite
      libxtrx
      #soapyairspy
      #soapyaudio
      #soapybladerf
      soapyhackrf
      soapyremote
      soapyrtlsdr
      #soapyuhd
    ];
  };
in
{
  boot.extraModulePackages = [ xtrx_linux_pcie_drv ];
  environment.systemPackages = [
    libxtrx
  ];

  services.udev.packages = [ libxtrxll ];
}
