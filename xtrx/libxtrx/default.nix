{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, cmake
, libxtrxll
, libxtrxdsp
, liblms7002m
, soapysdr
}:

stdenv.mkDerivation rec {
  pname = "libxtrx";
  version = "acb0b1c";

  src = fetchFromGitHub {
    owner = "xtrx-sdr";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "1cgbqq1kkd2w8jkrb99zpw14n408p4bwzqi43kqpr03vy837q2bn";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libxtrxll
    libxtrxdsp
    liblms7002m
    soapysdr
  ];

  fixupPhase = ''
    runHook preFixup

    mkdir $out/bin
    for pkg in $out/lib/xtrx/*; do
      ln -s $pkg $out/bin
    done

    runHook postFixup
  '';

  patches = [
    ./0000-fix-divide-by-zero.patch # https://github.com/xtrx-sdr/xtrx_linux_pcie_drv/pull/11
  ];

  meta = with lib; {
    homepage = "https://github.com/xtrx-sdr/libxtrx";
    description = "High-level XTRX API library";
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ marble ];
  };
}
