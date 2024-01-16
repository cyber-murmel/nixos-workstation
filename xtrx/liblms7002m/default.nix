{ lib
, stdenv
, fetchFromGitHub
, cmake
, python3
}:

stdenv.mkDerivation rec {
  pname = "liblms7002m";
  version = "b07761b";

  src = fetchFromGitHub {
    owner = "xtrx-sdr";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "03q2aj7s1q0lxssbyv4khaxg6vmn34yclnrzsjdargbfyads13ml";
  };

  buildInputs = [
    cmake
    (python3.withPackages (ps: with ps; [
      cheetah3
    ]))
  ];

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    homepage = "https://github.com/xtrx-sdr/liblms7002m";
    description = "Compact LMS7002M library suitable for resource-limited MCUs";
    platforms = platforms.all;
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ marble ];
  };
}
