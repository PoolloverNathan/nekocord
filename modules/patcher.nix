{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with config.install;
{
  options.install = {
    config = mkOption {
      description = "Nekocord configuration. Not fully documented. This is different than preferences!";
      type = types.attrsOf types.anything;
      default = { };
    };
    base = mkPackageOption pkgs "discord" { };
    renameBinary = mkOption {
      description = "Rename the binary to `nekocord` or a custom name. This is useful for having multiple modded clients.";
      type = with types; coercedTo bool (b: if b then "nekocord" else null) (nullOr singleLineStr);
      default = null;
    };
  };
  config.install = {
    config.loader = config.version.content + /dist/loader.min.js;
  };
  options.build = {
    configDir = mkOption {
      description = "The contents of Nekocord's configuration directly. This should usually be placed at `~/.config/nekocord`.";
      type = types.pathInStore;
      default =
        pkgs.runCommand "nekocord-config"
          {
            buildInputs = [ pkgs.jq ];
          }
          ''
            mkdir $out
            ln -s ${config.build.pluginsDir} $out/plugins
            ln -s ${config.build.themesDir} $out/themes
            ln -s ${pkgs.writeText "config.json" (builtins.toJSON config.install.config)} $out/config.json
            ln -s /tmp/nekocord-preferences.json $out/preferences.json
          '';
    };
    nekocord = mkOption {
      description = "Discord with Nekocord installed. Setting this manually is a bad idea!";
      type = types.pathInStore;
      default =
        let
          binaryName = "Discord";
        in
        base.overrideAttrs {
          postInstall = ''
            mv $out/opt/${binaryName}/resources/app.asar $out/opt/${binaryName}/resources/_app.asar
            cp ${config.version.content}/app.asar $out/opt/${binaryName}/resources/app.asar
            ${optionalString (renameBinary != null) # bash
              ''
                rm $out/bin/Discord
                mv $out/bin/discord $out/bin/${escapeShellArg renameBinary}
              ''
            }
          '';
        };
    };
  };
}
