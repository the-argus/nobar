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
    postPatch = ''
      wrapProgram $out/bin/eww \
          --add-flags "--config ${nobarEwwConfig}"
    '';
  };

  python = python310.withPackages (pythonPackages:
    with pythonPackages; [
      i3ipc
    ]);

  scripts = stdev.mkDerivation {
    name = "nobar-runtime-scripts";
    src = ./src;

    nativeBuildInputs = [
      # by including python this should cause shebangs to point to this
      # instance of python (hopefully)
      python
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/lib/python3.10/site-packages

      my py/isolate $out/bin
      my py/window-switcher $out/bin
      mv py $out/lib/python3.10/site-packages/nobar
    '';
  };

  runtime-path = lib.makeBinPath [
    wrappedEww
    scripts
  ];
in
  stdenv.mkDerivation {
    pname = "nobar";
    version = "alpha-1";

    src = ./src;

    nativeBuildInputs =
      [
        makeWrapper
      ]
      ++ runtime-path;

    installPhase = ''
      mkdir -p $out
      mkdir -p $out/share/nobar
      mkdir -p $out/bin

      mv nobar $out/bin/
      mv eww $out/share/nobar/
      mv sh $out/share/nobar/

    '';

    postPatch = ''
      wrapProgram $out/bin/nobar \
          --prefix PATH : ${runtime-path}
    '';
  }
