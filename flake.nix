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
      {
        formatter = pkgs.nixfmt;
        packages = rec {
          default = pkgs.resholve.writeScriptBin "my-script" {
            inputs = [
              pkgs.coreutils
              pkgs.jsonschema
              pkgs.yq-go
            ];
            fix = {
              "$KRM_SCHEMA" = [
                (pkgs.writeTextFile {
                  name = "krm.schema.json";
                  text = builtins.readFile ./krm.schema.json;
                })
              ];
            };
            execer = [
              "cannot:${pkgs.yq-go}/bin/yq"
              "cannot:${pkgs.jsonschema}/bin/jv"
            ];
            interpreter = "${pkgs.runtimeShell}";
          } (builtins.readFile ./script.sh);
          docker = pkgs.dockerTools.buildImage {
            name = "playground";
            config = {
              Cmd = [ "${default}" ];
            };
          };
        };
      }
    );
}
