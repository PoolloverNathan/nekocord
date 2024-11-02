{
  pkgs,
  lib,
  config,
  prefix,
  ...
}:
with lib;
with config.version;
{
  options.version = {
    branch = mkOption {
      description = "The branch of Nekocord to use.";
      type = types.str;
      default = "main";
      example = "dev";
    };
    buildId =
      mkOption {
        description = "The Nekocord build number to use.";
        type = types.ints.positive;
      }
      // optionalAttrs (nekocord.latest.nekocord ? ${branch}) {
        default = throw "nekocord.buildId must be expliclty defined. The latest buildId on the ${branch} branch is ${
          builtins.toString (nekocord.latest.nekocord.${branch})
        }.";
      };
    url = mkOption {
      description = "The URL to fetch Nekocord from. This should not need to be manually specified.";
      type = types.strMatching "https?://.+";
      default = nekocord.buildURL {
        inherit branch;
        id = buildId;
      };
    };
    hash = mkOption {
      description = "Nekocord's hash. Used for purity. If unsure, Nix will happily tell you!";
      type = types.str;
      default = fakeHash;
    };
    content = mkOption {
      description = "The Nekocord bundle to use. This will be fetched if left unspecified.";
      type = types.path;
      default = pkgs.fetchzip {
        inherit url hash;
        stripRoot = false;
      };
    };
  };
}
