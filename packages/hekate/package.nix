{
  stdenv,
  fetchFromGitHub,

  devkitARM,
}: stdenv.mkDerivation (finalAttrs: {
  pname = "Hekate";
  version = "6.2.2";

  src = fetchFromGitHub {
    owner = "CTCaer";
    repo = "hekate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4vPVGBs9lpgKuSRK7eMhrEy8KA2TmAcxKK4Hg4aCImo=";
  };

  buildInputs = [
    devkitARM 
  ];

  DEVKITPRO = "${devkitARM}";

})
