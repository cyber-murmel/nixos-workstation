{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, cmake
, libusb3380
}:

stdenv.mkDerivation rec {
  pname = "libxtrxll";
  version = "1b6eddf";

  src = fetchFromGitHub {
    owner = "xtrx-sdr";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "145rsirqqgh2j60zx9bzvg8qwvbkff889cp4aglajw26p90spn4c";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libusb3380
  ];

  cmakeFlags = [
    "-DINSTALL_UDEV_RULES=ON"
    "-DUDEV_RULES_PATH=lib/udev/rules.d"
  ];

  fixupPhase = ''
    runHook preFixup

    mkdir $out/bin
    for pkg in $out/lib/xtrxll/*; do
      ln -s $pkg $out/bin
    done

    runHook postFixup
  '';

  meta = with lib; {
    homepage = "https://github.com/xtrx-sdr/libxtrxll";
    description = "Low-level XTRX hardware abstraction library";
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ marble ];
  };
}
