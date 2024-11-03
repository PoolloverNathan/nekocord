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
    base = mkOption {
      description = "The Discord package to use. By default, Discord itself is used, with openasar, tts, and vencord (experimental) being used to create the base package.";
      type = types.pathInStore;
      default = pkgs.discord.override {
        withOpenASAR = openasar;
        withVencord = vencord;
        withTTS = tts;
      };
    };
    openasar = mkEnableOption "OpenASAR";
    tts = mkEnableOption "TTS" // {
      default = true;
    };
    vencord = mkEnableOption "Vencord";
    renameAsar = mkOption {
      description = "What to rename the original app.asar to. This must be changed if you are using Vencord.";
      type = types.singleLineStr;
      default = "_app.asar";
    };
    renameBinary = mkOption {
      description = "Rename the binary to `nekocord` or a custom name. This is useful for having multiple modded clients.";
      type = with types; coercedTo bool (b: if b then "nekocord" else null) (nullOr singleLineStr);
      default = null;
    };
  };
  config.install = {
    config.loader =
      (
        if renameAsar != "_app.asar" then
          pkgs.runCommand "nekocord-dist" { } ''
            cp -r ${config.version.content}/dist $out
            chmod +w $out $out/loader.min.js
            sed -i 's/\b_app\.asar\b/'${escapeShellArg renameAsar}/ $out/loader.min.js
          ''
        else
          config.version.content + /dist
      )
      + /loader.min.js;
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
        assert renameAsar != "app.asar";
        assert vencord -> renameAsar != "_app.asar";
        let
          binaryName = "Discord";
        in
        base.overrideAttrs (
          super:
          {
            nativeBuildInputs =
              super.nativeBuildInputs or [ ]
              ++ optional (renameAsar != "_app.asar") [ pkgs.asar ];
            postInstall = ''
              set -x
              ${super.postInstall or ""}
              mv $out/opt/${binaryName}/resources/app.asar $out/opt/${binaryName}/resources/${escapeShellArg renameAsar}
              ${
                if renameAsar != "_app.asar" then
                  # bash
                  ''
                    asar e ${config.version.content}/app.asar asar
                    sed -i 's/\b_app\.asar\b/'${escapeShellArg renameAsar}/ asar/index.js
                    asar p asar $out/opt/${binaryName}/resources/app.asar
                  ''
                else
                  # bash
                  ''
                    cp ${config.version.content}/app.asar $out/opt/${binaryName}/resources/app.asar
                  ''
              }
              ${optionalString (renameBinary != null) # bash
                ''
                  rm $out/bin/Discord
                  mv $out/bin/discord $out/bin/${escapeShellArg renameBinary}
                ''
              }
              set +x
            '';
          }
          // optionalAttrs (renameBinary != null) {
            meta = super.meta or { } // {
              mainProgram = renameBinary;
            };
          }
        );
    };
  };
}
