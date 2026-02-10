{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
rec {

  inherit (pkgs)
    stdenv
    pkgsStatic
    busybox
    hello
    coreutils
    jq
    bash
    ;

  # minimal derivation
  minimal = derivation {
    name = "minimal";
    system = builtins.currentSystem; # the platform to realise this drv (Build Machine)
    builder = "/bin/sh"; # libstore provide a default `/bin/sh` (namely `ash` from BusyBox) in build sandbox   # https://github.com/NixOS/nix/blob/e4ce788f9d8de1bc5e58002d01088cd71c6703d0/doc/manual/source/release-notes/rl-2.0.md?plain=1#L504/L506
    args = [
      "-c"
      "echo hello > $out" # create the $out
    ];
  };

  dep1 = derivation {
    name = "dep1";
    system = builtins.currentSystem;
    builder = "/bin/sh";
    args = [
      "-c"
      "echo dep1 > $out"
    ];
  };

  dep2 = derivation {
    name = "dep2";
    system = builtins.currentSystem;
    builder = "/bin/sh";
    args = [
      "-c"
      "echo ${dep1} > $out"
    ];
  };

  fin1 = derivation {
    name = "fin1";
    system = builtins.currentSystem;
    builder = "/bin/sh";
    args = [
      "-c"
      "echo ${dep2} > $out"
    ];
  };

  # Get run/build time dependency
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/closure-info.nix
  graph = derivation {
    name = "graph";
    system = builtins.currentSystem;
    __structuredAttrs = true;
    exportReferencesGraph.closure = [ fin1 ]; # build time dependency: hello.drvPath
    builder = "${bash}/bin/bash";
    args = [
      "-c"
      ''
        . $NIX_ATTRS_SH_FILE
        out=''${outputs[out]}
        ${coreutils}/bin/mkdir -p $out
        ${coreutils}/bin/cat $NIX_ATTRS_JSON_FILE > $out/attr.json
        ${coreutils}/bin/cat $NIX_ATTRS_SH_FILE > $out/attr.sh
        ${coreutils}/bin/printenv > $out/env
      ''
    ];
  };

  # unsafeDiscardReferences can disable scanning the output for runtime dependencies.
  noRef = derivation {
    name = "noRef";
    system = builtins.currentSystem;
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
    builder = "${bash}/bin/bash";
    args = [
      "-c"
      ''
        . $NIX_ATTRS_SH_FILE
        out=''${outputs[out]}
        echo ${dep1} > $out
      ''
    ];
  };

  # In sandbox, only inputs runtime closure is visible

  # m3dxfi2gq218pw8h73al024f6r69a5mj-busybox-1.37.0            <- libstore(nix-store) provide a default `/bin/sh`
  # s138s93hk24db2jdplbi9k768pqhx6h1-visible-path              <- $out
  # 6in5jlbspq9szjvlrdxq9rpmxyvca529-busybox-1.37.0            <- ${busybox}/bin/ls  -al /nix/store > $out
  # wb6rhpznjfczwlwx23zmdrrw74bayxw4-glibc-2.42-47             <- ${busybox} runtime dependency
  # kbijm6lc9va8xann3cfyam0vczzmwkxj-xgcc-15.2.0-libgcc
  # d0d9wqmw5saaynfvmszsda3dmh5q82z8-libidn2-2.3.8
  # pkphs076yz5ajnqczzj0588n6miph269-libunistring-1.4.1
  visible-path = derivation {
    name = "visible-path";
    system = builtins.currentSystem;
    builder = "/bin/sh";
    args = [
      "-c"
      "${busybox}/bin/ls  -al /nix/store > $out"
    ];
  };

  transmission = pkgs.callPackage ./transmission.nix { };
}
