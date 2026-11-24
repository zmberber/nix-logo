{
  description = "The Nix logo written in pure Nix";
  outputs = {
    self
  }:
  let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "armv6l-linux"
      "armv7l-linux"
      "i686-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "powerpc64le-linux"
      "riscv64-linux"
      "x86_64-freebsd"
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
    inherit nix-logo;
    packages = inAllSystems {
      inherit nix-logo;
      default = nix-logo;
    };
  };
}
