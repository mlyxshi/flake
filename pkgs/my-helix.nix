{
  stdenv,
  helix,
}:
stdenv.mkDerivation {
  inherit (helix) pname version meta;
  __structuredAttrs = true;
  unsafeDiscardReferences.out = true;
  # helix depend on 
  #1. helix runtime(tree-sitter grammars/queries)
  #2. glic
  #3. gcc-lib 
  # I do not want huge unuesd grammers in my disk 
  # It is safe to discard all dependencies, beacuse gcc-lib/glic are also used in other binaray as runtime dependency, so helix can always find them in /nix/store
  buildCommand = ''
    mkdir -p $out/bin
    cp ${helix}/bin/hx $out/bin
  '';
}
