{ pkgs, lib, ... }: {
	options.build.themesDir = lib.mkOption {
		internal = true;
		type = lib.types.pathInStore;
	};
	config.build.themesDir = pkgs.runCommand "themes" {} "mkdir $out";
}
