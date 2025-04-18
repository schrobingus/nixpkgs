{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libcosmicAppHook,
  just,
  nasm,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-bg";
  version = "1.0.0-alpha.6";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-bg";
    tag = "epoch-${finalAttrs.version}";
    hash = "sha256-4b4laUXTnAbdngLVh8/dD144m9QrGReSEjRZoNR6Iks=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-GLXooTjcGq4MsBNnlpHBBUJGNs5UjKMQJGJuj9UO2wk=";

  nativeBuildInputs = [
    just
    libcosmicAppHook
    nasm
  ];

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-bg"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "unstable"
      "--version-regex"
      "epoch-(.*)"
    ];
  };

  meta = {
    homepage = "https://github.com/pop-os/cosmic-bg";
    description = "Applies Background for the COSMIC Desktop Environment";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [
      nyabinary
      HeitorAugustoLN
    ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-bg";
  };
})
