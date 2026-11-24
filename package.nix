{
  size ? 256,
  logoColor ? "#7EBAE4",
}:

let
  pointsToString = (
    points:
    builtins.concatStringsSep
    " "
    (map (p: "${toString p.x},${toString p.y}") points)
  );

  polygon = (
    { points, attrs }:
    let
      svgPoints = pointsToString points;
      attrStr = (
        builtins.concatStringsSep
        " "
        (
          builtins.attrValues
          (builtins.mapAttrs (k: v: ''${k}="${v}"'') attrs)
        )
      );
    in
    ''<polygon points="${svgPoints}" ${attrStr}/>''
  );

  svg = ''
    <svg xmlns="http://www.w3.org/2000/svg" width="${toString size}" height="${toString size}">
      ${polygon {
        points = [
          { x = size / 2; y = size * 0.1; }
          { x = size * 0.9; y = size * 0.9; }
          { x = size * 0.1; y = size * 0.9; }
        ];
        attrs = {
          fill = logoColor;
        };
      }}
    </svg>
  '';
in
builtins.toFile "nix-logo.svg" svg
