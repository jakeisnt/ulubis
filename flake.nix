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
          ];

          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          # This allows the acl2s Z3 extension to dynamically link with the Z3 library.
          # It might not require the `include` extension provided.
          CPATH = "${pkgs.z3.lib}/include:$CPATH";
          # this `makeLibraryPath` is necessary to provide `libcrypto` to `hunchentoot`.
          # This allows users to build acl2, which depends on hunchentoot!
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath [pkgs.openssl]}:${pkgs.openssl.dev}/lib:${pkgs.openssl}/lib:${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.z3.lib}/lib:$LD_LIBRARY_PATH";
        };
      }
    );
}
