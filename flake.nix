{
  description = "The Nix logo written in pure Nix";
  outputs = {
    self
  }:
  let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    inAllSystems = (
      v:
      builtins.listToAttrs (
	map
	(system: { name = system; value = v; })
	systems
      )
    );
    nix-logo = import ./package.nix { };
  in
  {
    packages = inAllSystems {
      inherit nix-logo;
      default = nix-logo;
    };
  };
}
