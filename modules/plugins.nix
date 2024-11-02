{ pkgs, lib, ... }:
{
  options.build.pluginsDir = lib.mkOption {
    internal = true;
    type = lib.types.pathInStore;
  };
  config.build.pluginsDir = pkgs.runCommand "plugins" { } "mkdir $out";
}
