{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.themes = lib.mkOption {
    description = ''
      A list of themes to install.
    '';
    type =
      with lib.types;
      import ../namedAttrsOf.nix lib (name: coercedTo lines (builtins.toFile "${name}.css") path);
    default = { };
  };
  options.build.themesDir = lib.mkOption {
    internal = true;
    type = lib.types.pathInStore;
  };
  config.build.themesDir = pkgs.runCommand "themes" { } ''
    mkdir $out
    ${lib.concatLines (
      lib.mapAttrsToList (
        name: path: # bash
        ''
          ln -vs ${path} $out/${lib.escapeShellArg name}.css
        '') config.themes
    )}
  '';
}
