{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        formatter = pkgs.nixfmt;
        packages = pkgs.lib.attrsets.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
          targetSystem:
          let
            pkgs = import nixpkgs {
              localSystem = system;
              crossSystem = targetSystem;
            };
          in
          rec {
            script = pkgs.writeShellApplication {
              name = "script";
              text = builtins.readFile ./script.sh;
              runtimeInputs = [
                pkgs.coreutils
                pkgs.jsonschema
                pkgs.yq
              ];
              runtimeEnv = {
                "KRM_SCHEMA" = (
                  pkgs.writeTextFile {
                    name = "krm.schema.json";
                    text = builtins.readFile ./krm.schema.json;
                  }
                );
              };
              inheritPath = false;
            };
            docker = pkgs.dockerTools.buildImage {
              name = "playground";
              config = {
                Cmd = [ "${script}" ];
              };
            };
          }
        );
      }
    );
}
