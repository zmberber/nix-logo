{
  lib,
  writeTextFile,
  option1 ? ...,
  option2 ? ...,
}:

let
  helper1 = ...;
  helper2 = ...;
in
let
  svg = ''...'';
in
writeTextFile {
  name = "nix-logo";
  destination = "/share/nix-logo.svg";
  text = svg;
}
