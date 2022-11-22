{
  description = "window compositor";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        dir = "$HOME/car";
        buildInputs = with pkgs; [ sbcl openssl libressl z3 gcc pkg-config zlib clang ];
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            sbcl
            openssl
            libressl
            z3
            z3.lib
            gcc
            pkg-config
            zlib
            clang
            autoreconfHook
            xorg.libX11
            xorg.libXi
            xorg.libXext
            libGLU
            zlib
            glibc.out
            glibc.static
            libpng
            nasm
            cairo
            pango
            libGL
            driversi686Linux.mesa
            libdrm
            mesa
            libxkbcommon
            libinput
            libuuid # canvas
          ];

          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          # This allows the acl2s Z3 extension to dynamically link with the Z3 library.
          # It might not require the `include` extension provided.
          CPATH = "${pkgs.libGLU}:${pkgs.z3.lib}/include:$CPATH";
          # this `makeLibraryPath` is necessary to provide `libcrypto` to `hunchentoot`.
          # This allows users to build acl2, which depends on hunchentoot!
          LD_LIBRARY_PATH = "${with pkgs; lib.makeLibraryPath [

            #TODO: we're stuck on libgbm - not sure where it is' now its a bit of a mess..
            libxkbcommon libinput
            driversi686Linux.mesa mesa libGLU libGL libuuid cairo libdrm]}:${pkgs.lib.makeLibraryPath [pkgs.openssl]}:${pkgs.openssl.dev}/lib:${pkgs.openssl}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.z3.lib}/lib:$LD_LIBRARY_PATH";
          shellHook = ''
                    LD=$CC
            '';
        };
      }
    );
}
