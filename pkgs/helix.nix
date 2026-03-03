{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  mdbook,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "helix";
  version = "25.07.1";

  outputs = [
    "out"
    "doc"
  ];

  src = fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    tag = "${finalAttrs.version}";
    hash = "sha256-RFSzGAcB0mMg/02ykYfTWXzQjLFu2CJ4BkS5HZ/6pBo=";
  };

  cargoHash = "sha256-Mf0nrgMk1MlZkSyUN6mlM5lmTcrOHn3xBNzmVGtApEU=";

  patches = [
    # Support mdbook 0.5.x: escape HTML tags in command descriptions
    ./mdbook-0.5-support.patch
  ];

  postPatch = ''
    # mdbook 0.5 uses asset hashing for CSS/JS files
    # Remove custom theme to use default mdbook theme with correct asset references
    rm -f book/theme/index.hbs
  '';

  nativeBuildInputs = [
    installShellFiles
    mdbook
  ];

  env = {
    # disable fetching and building of tree-sitter grammars in the helix-term build.rs
    HELIX_DISABLE_AUTO_GRAMMAR_BUILD = "1";
    HELIX_DEFAULT_RUNTIME = "${finalAttrs.src}/runtime";
  };

  postBuild = ''
    mdbook build book -d ../book-html
  '';

  postInstall = ''
    mkdir -p $out/lib $doc/share/doc
    installShellCompletion contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
    cp contrib/Helix.desktop $out/share/applications/Helix.desktop
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps/helix.png
    cp -r ../book-html $doc/share/doc/$name
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  versionCheckProgram = "${placeholder "out"}/bin/hx";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Post-modern modal text editor";
    homepage = "https://helix-editor.com";
    changelog = "https://github.com/helix-editor/helix/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    mainProgram = "hx";
    maintainers = with lib.maintainers; [
      aciceri
      danth
      yusdacra
    ];
  };
})
