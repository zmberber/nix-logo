{
  writeTextFile,
  opts ? {},
  lib,
  ...
}:
let
  tools = import ../tools { inherit lib; };
  mylib = import ../mylib { inherit lib tools; };
  defaultOpts = {
    logoColor = "#7EBAE4";
    size = 256;
  };
  
  cfg = defaultOpts // opts;
  
  s = cfg.size;

  svg = ''
    <svg xmlns="http://www.w3.org/2000/svg" width="${toString s}" height="${toString s}">
      ${mylib.svg.polygon {
        points = [
          { x = s / 2; y = s * 0.1; }
          { x = s * 0.9; y = s * 0.9; }
          { x = s * 0.1; y = s * 0.9; }
        ];
        attrs = {
          fill = cfg.logoColor;
        };
      }}
    </svg>
  '';
in
writeTextFile {
  name = "nix-logo";
  destination = "/nix-logo.svg";
  text = svg;
}
