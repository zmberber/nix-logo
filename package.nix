{
  system,
  ...
}@arguments:
derivation {
  name = "nix-logo.svg";
  inherit system;
  builder = "/bin/sh";
  args = [ "-c" ''printf '%s' "$svgText" > "$out"'' ];
  svgText = import ./svg.nix arguments;
}
