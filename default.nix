{
  stdenv,
  lib,
  makeWrapper,
  eww,
  python310,
  xkb-switch,
  playerctl,
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

  python = python310.withPackages (pythonPackages:
    with pythonPackages; [
      i3ipc
      nobar-python-lib
    ]);

  scripts = stdenv.mkDerivation {
    name = "nobar-runtime-scripts";
    src = ./src;

    nativeBuildInputs = [makeWrapper];

    buildInputs = [python];

    installPhase = ''
      mkdir -p $out/bin
      mv py/* $out/bin
      mv sh/* $out/bin
    '';
  };

  wrappedEww = stdenv.mkDerivation {
    name = "nobar-wrapped-eww";
    src = eww;
    nativeBuildInputs = [makeWrapper];
    buildInputs = [scripts];
    installPhase = "cp -r $src $out";
    preFixup = ''
      wrapProgram $out/bin/eww \
          --add-flags "--config ${nobarEwwConfig}/share/nobar/eww"
    '';
  };

  nobar-python-lib = stdenv.mkDerivation {
    name = "nobar-python-lib";
    src = ./src/py/nobar;
    installPhase = ''
      mkdir -p $out/lib/python3.10/site-packages/
      mv . $out/share/lib/python3.10/site-packages/nobar
    '';
  };

  runtime-deps = [
    wrappedEww
    scripts
    xkb-switch
    playerctl
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
        python
      ]
      ++ runtime-deps;

    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/nobar
      mkdir -p $out/bin

      mv nobar $out/bin/
    '';

    postFixup = ''
      wrapProgram $out/bin/nobar \
          --prefix PATH : ${runtime-path}
    '';
  }
