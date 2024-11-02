{
	pkgs ? import <nixpkgs> { config.allowUnfree = true; },
	nekocord ? builtins.getFlake "${builtins.getEnv "PWD"}",
}: nekocord.lib.patch pkgs {
	install.renameBinary = true;
	version = {
		buildId = 291;
		hash = sha256:lEOWaIGAQlWdno/bybtY/BB2Frt7XZDS1TRw3e3DruI=;
	};
}
