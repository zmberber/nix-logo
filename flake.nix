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
      inAllSystems = f: builtins.listToAttrs
        (map (system: { name = system; value = f system; }) systems)
      ;
    in
    {
      packages = inAllSystems (system: rec {
        nix-logo = import ./package.nix { inherit system; };
        default = nix-logo;
      });
    };
}
