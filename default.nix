{
  stdenv,
  lib,
  makeWrapper,
  eww,
  python310,
  ...
}: let
  nobarEwwConfig = stdenv.mkDerivation {
    name = "nobar-eww-config";
    src = ./src;
    installPhase = ''
      mkdir -p $out/share/nobar
      mv eww $out/share/nobar
    '';
  };

  wrappedEww = stdenv.mkDerivation {
    name = "nobar-wrapped-eww";
    src = eww;
    nativeBuildInputs = [makeWrapper];
    installPhase = "cp -r $src $out";
    preFixup = ''
      wrapProgram $out/bin/eww \
          --add-flags "--config ${nobarEwwConfig}/share/nobar/eww"
    '';
  };

  python = python310.withPackages (pythonPackages:
    with pythonPackages; [
      i3ipc
    ]);

  scripts = stdenv.mkDerivation {
    name = "nobar-runtime-scripts";
    src = ./src;

    nativeBuildInputs = [makeWrapper];

    buildInputs = [python];

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib/python3.10/site-packages

      mv py/nobar $out/lib/python3.10/site-packages
      mv py/* $out/bin
      mv sh/* $out/bin
    '';
  };

  runtime-deps = [
    wrappedEww
    scripts
  ];
  runtime-path = lib.makeBinPath runtime-deps;
in
  stdenv.mkDerivation {
    pname = "nobar";
    version = "alpha-1";

    src = ./src;

    nativeBuildInputs =
      [
        makeWrapper
      ]
      ++ runtime-deps;

    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/nobar
      mkdir -p $out/bin

      mv nobar $out/bin/
      mv eww $out/share/nobar/
      mv sh $out/share/nobar/

      ln -sf ${scripts}/bin $out/runtime-deps
    '';

    postFixup = ''
      wrapProgram $out/bin/nobar \
          --prefix PATH : ${runtime-path}
    '';
  }
