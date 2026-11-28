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
    mkLogo = args: import ./package.nix args;
  in
  {
    lib = {
      mkSvg = args: import ./svg.nix args;
      inherit mkLogo;
    };
    packages = inAllSystems (
      system:
      let
        mkLogo' = args: mkLogo ({ inherit system; } // args);
      in
      rec {
	default = nix-logo;
        nix-logo = mkLogo' { };
        nix-logo-pride = mkLogo' {
          colors = [ "#c10100" "#5a37bb" "#0088cc" "#029b3b" "#fdb00b" "#ff6705" ];
        };
        nix-logo-trans = mkLogo' {
          colors = [ "#f5a9b8" "#5bcefa" "#ffffff" "#f5a9b8" "#5bcefa" "#ffffff" ];
        };
	nix-logo-styleguide = mkLogo' {
	  neck = 5;
	  gap = 0.125;
	};
	nix-logo-black = mkLogo' {
	  colors = [ "#000000" "#000000" "#000000" "#000000" "#000000" "#000000" ];
	};
	nix-logo-white = mkLogo' {
	  colors = [ "#FFFFFF" "#FFFFFF" "#FFFFFF" "#FFFFFF" "#FFFFFF" "#FFFFFF" ];
	};
	nix-logo-nogap = mkLogo' {
	  gap = 0;
	};
	nix-logo-anarchy = mkLogo' {
	  colors = [ "#000000" "#FF111111" "#000000" "#FF111111" "#000000" "#FF1111" ];
	};
	# nix-logo-old = mkLogo' { }; # todo, as close as possible to old
      }
    );
  };
}
