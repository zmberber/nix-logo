{
  lib,
  ...
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
in
{
  inherit
    pointsToString
    polygon
  ;
}
