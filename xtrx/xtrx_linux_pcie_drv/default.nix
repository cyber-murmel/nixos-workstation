{ stdenv, lib, fetchFromGitHub, kernel, cmake }:

stdenv.mkDerivation rec {
  pname = "xtrx_linux_pcie_drv";
  version = "5ae3a3e";

  src = fetchFromGitHub {
    owner = "xtrx-sdr";
    repo = "${pname}";
    rev = "${version}";
    sha256 = "084yp8imrp77yjwpykh5pj1jvbl5bbah3v59zvc5cxy2by77iihh";
  };

  # nativeBuildInputs = kernel.moduleBuildDependencies ++ [
  #   cmake
  # ];
  # propagatedBuildInputs = [
  #   libusb
  # ];

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  # makeFlags = [
  #   "ARCH=arm64"
  #   "CROSS_COMPILE=aarch64-unknown-linux-gnu-
  #   "KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
  #   "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
  # ];

  #phases = [ "buildPhase" "installPhase" ];

  patches = [
    ./0000-remove-major-minor.patch # https://github.com/xtrx-sdr/xtrx_linux_pcie_drv/pull/11
    ./0000-rk3399.patch
  ];

  buildPhase = ''
    make \
      -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      modules
  '';

  installPhase = ''
    mkdir $out
    make \
      -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      INSTALL_MOD_PATH=$out \
      modules_install
  '';

  # buildPhase = ''
  #   make \
  #     ARCH=arm64 \
  #     CROSS_COMPILE=aarch64-unknown-linux-gnu- \
  #     -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
  #     M=$(pwd) \
  #     modules
  # '';

  # installPhase = ''
  #   mkdir $out
  #   make \
  #     ARCH=arm64 \
  #     CROSS_COMPILE=aarch64-unknown-linux-gnu- \
  #     -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
  #     M=$(pwd) \
  #     INSTALL_MOD_PATH=$out \
  #     modules_install
  # '';

  meta = with lib; {
    homepage = "https://github.com/xtrx-sdr/xtrx_linux_pcie_drv";
    description = "XTRX PCI driver for linux";
    platforms = platforms.all;
    maintainers = with maintainers; [ marble ];
  };
}
