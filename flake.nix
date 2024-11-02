{
	inputs.nixpkgs.url = github:nixos/nixpkgs;
	inputs.nekocord-latest = { url = https://nekocord.dev/uploads/nekocord/main/latest.json; flake = false; };
	inputs.nekocord-latest-dev = { url = https://nekocord.dev/uploads/nekocord/dev/latest.json; flake = false; };
	inputs.nekocord-installer = { url = https://nekocord.dev/uploads/nekocord-installer/main/latest.json; flake = false; };
	outputs = { self, nixpkgs, nekocord-latest, nekocord-latest-dev, nekocord-installer }: rec {
		lib = rec {
			latest.nekocord.main = builtins.fromJSON (nixpkgs.lib.importJSON nekocord-latest).build;
			latest.nekocord.dev = builtins.fromJSON (nixpkgs.lib.importJSON nekocord-latest-dev).build;
			latest.nekocord-installer.main = builtins.fromJSON (nixpkgs.lib.importJSON nekocord-installer).build;
			buildURL = {
				project ? "nekocord",
				branch ? "main",
				id ? latest.${project}.${branch} or (throw "Build ID must be specified for unlocked channel ${project}:${branch}"),
			}: "https://nekocord.dev/uploads/${project}/${branch}/${builtins.toString id}/${project}.zip";
			fetchBuild = {
				hash ? nixpkgs.lib.fakeHash,
				system,
				version ? {},
			}@args: nixpkgs.legacyPackages.${system}.fetchzip {
				url = buildURL version;
				inherit hash;
				stripRoot = false;
			};
			patch' = pkgs: prefix: modules: nixpkgs.lib.evalModules {
				inherit prefix;
				class = "nekocord";
				modules = builtins.attrValues nekocordModules ++ modules;
				specialArgs.nekocordFlake = self;
				specialArgs.pkgs = pkgs;
				specialArgs.lib = nixpkgs.lib // { nekocord = self.lib; };
			};
			patch = pkgs: module: (patch' pkgs [] [module]).config;
		};
		nekocordModules = import ./modules;
		packages = nixpkgs.lib.mapAttrs (system: pkgs: {
			default = lib.fetchBuild {
				inherit system;
				hash = sha256:lEOWaIGAQlWdno/bybtY/BB2Frt7XZDS1TRw3e3DruI=;
			};
			dev = lib.fetchBuild {
				inherit system;
				version.branch = "dev";
				hash = sha256:0Y8QQg/Evg89vDAlPqEAZ8m7vPlhwLDBZmyL4UeQ64I=;
			};
			installer = lib.fetchBuild {
				inherit system;
				version.project = "nekocord-installer";
			};
			discord = lib.patch pkgs {};
		}) nixpkgs.legacyPackages;
	};
}