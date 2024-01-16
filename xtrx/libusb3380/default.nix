{ lib
, stdenv
, fetchFromGitHub
, cmake
, libusb
}:

stdenv.mkDerivation rec {
  pname = "libusb3380";
  version = "c83d1e9";

  src = fetchFromGitHub {
    owner = "xtrx-sdr";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "1ky2bddb3rwrp5d3nnw8zzpkvi40cjdvnhcrzskas6w0glv08zf6";
  };

  nativeBuildInputs = [
    cmake
  ];
  propagatedBuildInputs = [
    libusb
  ];

  meta = with lib; {
    homepage = "https://github.com/xtrx-sdr/libusb3380";
    description = "USB3380 abstraction layer for libusb";
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ marble ];
  };
}
