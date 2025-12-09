{
  description = "rs-cmake - Reusable CMake modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://rslib.cachix.org" ];
    extra-trusted-public-keys = [
      "rslib.cachix.org-1:8OHneG2sLeTDlsZ4AZyNh8zx2zAwoiZUKVPnl21B+58="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
      pre-commit-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs.nixfmt.enable = true;

          settings.formatter = {
            gersemi = {
              command = pkgs.gersemi;
              options = [
                "-i"
                "--indent"
                "2"
              ];
              includes = [
                "CMakeLists.txt"
                "*.cmake"
              ];
              excludes = [
                "cmake/CPM.cmake"
              ];
            };

            nixfmt = {
              includes = [ "*.nix" ];
            };
          };
        };

        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            treefmt = {
              enable = true;
              package = treefmtEval.config.build.wrapper;
            };
          };
        };
        rs-cmake = pkgs.stdenv.mkDerivation {
          pname = "rs-cmake";
          version = "1.0.0";

          src = ./.;

          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            mkdir -p $out/share/cmake/rs-cmake
            cp -r cmake/* $out/share/cmake/rs-cmake/
          '';

          meta = with pkgs.lib; {
            description = "Reusable CMake modules for C/C++ projects";
            homepage = "https://github.com/rslib/cmake";
            license = licenses.mit;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cmake
            treefmtEval.config.build.wrapper
          ];

          shellHook = ''
            ${pre-commit-check.shellHook}
            echo "rs-cmake development environment"
            echo "Run 'treefmt' to format all files"
          '';
        };

        formatter = treefmtEval.config.build.wrapper;

        checks = {
          formatting = treefmtEval.config.build.check self;
          pre-commit-check = pre-commit-check;
        };

        packages = {
          inherit rs-cmake;
          default = rs-cmake;
        };
      }
    )
    // {
      overlays.default = final: prev: {
        rs-cmake = self.packages.${prev.system}.rs-cmake;
      };
    };
}
