{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  pkg-config,
  hackrf,
  libbladeRF,
  libusb1,
  limesuite,
  ncurses,
  rtl-sdr,
  soapysdr-with-plugins,
}:

stdenv.mkDerivation rec {
  pname = "dump1090";
  version = "9.0";

  src = fetchFromGitHub {
    owner = "flightaware";
    repo = "dump1090";
    rev = "v${version}";
    sha256 = "sha256-rc4mg+Px+0p2r38wxIah/rHqWjHSU0+KCPgqj/Gl3oo=";
  };

  patches = [
    # GCC 14 fix, remove when included in release
    (fetchpatch {
      url = "https://github.com/flightaware/dump1090/commit/eb08fd7fce8d133b0e7a0d45d0cb9423b09ddc55.patch";
      hash = "sha256-le9rDeU4+r2kROjCuqt0cSN4pPkwfiD4YTdM9qFeYyQ=";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    hackrf
    libbladeRF
    libusb1
    ncurses
    rtl-sdr
    soapysdr-with-plugins
  ] ++ lib.optional stdenv.hostPlatform.isLinux limesuite;

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-implicit-function-declaration -Wno-int-conversion -Wno-unknown-warning-option";

  buildFlags = [
    "DUMP1090_VERSION=${version}"
    "showconfig"
    "dump1090"
    "view1090"
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -v dump1090 view1090 $out/bin
    cp -vr public_html $out/share/dump1090

    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple Mode S decoder for RTLSDR devices";
    homepage = "https://github.com/flightaware/dump1090";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ earldouglas ];
  };
}
