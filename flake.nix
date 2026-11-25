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
      packages =
        inAllSystems
        (
          system:
          let
            mkLogo = args: import ./package.nix ({ inherit system; } // args);
          in
          rec {
            nix-logo = mkLogo { };
            default = nix-logo;
            nix-logo-pride = mkLogo {
              colors = [ "#c10100" "#5a37bb" "#0088cc" "#029b3b" "#fdb00b" "#ff6705" ];
            };
            nix-logo-trans = mkLogo {
              colors = [ "#f5a9b8" "#5bcefa" "#ffffff" "#f5a9b8" "#5bcefa" "#ffffff" ];
            };
          }
        );
    };
}
