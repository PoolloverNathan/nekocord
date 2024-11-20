{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
  nekocord ? builtins.getFlake "${builtins.getEnv "PWD"}",
}:
nekocord.lib.patch pkgs {
  install.renameBinary = true;
  install.openasar = true;
  version = {
    buildId = 330;
    hash = "sha256-YtIkeKEdKiW4y/Sdzn61NCMJ/6w5ghAPzqF6A9dU77M=";
  };
}
