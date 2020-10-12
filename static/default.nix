{pkgs ? (import ../.obelisk/impl {}).reflex-platform.nixpkgs} :
let
    jexcel = import deps/jexcel/thunk.nix;
    jsuites = import deps/jsuites/thunk.nix;
in pkgs.stdenv.mkDerivation {
    name ="staticFiles";
    src = ./.;
    builder = pkgs.writeScript "builder.sh" ''
      source "$stdenv/setup"
      mkdir -p $out
      cp -r $src/main.css $out
      cp -r $src/obelisk.jpg $out
      mkdir -p $out/jexcel
      cp -r ${jexcel}/dist/jexcel.css $out/jexcel/jexcel.css
      cp -r ${jexcel}/dist/jexcel.js $out/jexcel/jexcel.js
      mkdir -p $out/jsuites
      cp -r ${jsuites}/dist/jsuites.css $out/jsuites/jsuites.css
      cp -r ${jsuites}/dist/jsuites.js $out/jsuites/jsuites.js
    '';
  }
