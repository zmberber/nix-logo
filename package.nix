{
  system,
  size ? 1024,
  resolution ? 16,
  gap ? 0.25,
  thickness ? 1,
  colors ? [ "#5277C3" "#7EBAE4" "#5277C3" "#7EBAE4" "#5277C3" "#7EBAE4" ],
  hals ? 4,
  pad ? 0,
}:
let
  # vector space basis vectors for triangular lattice
  O = { i = 0; j = 0; }; # origin
  I = scale resolution { i = 1; j = 0; }; # basis vector 1
  J = scale resolution { i = 0; j = 1; }; # basis vector 2
  K = scale resolution { i = -1; j = 1; }; # J - I
  mI = scale resolution { i = -1; j = 0; }; # -I
  mJ = scale resolution { i = 0; j = -1; }; # -J
  mK = scale resolution { i = 1; j = -1; }; # -K
  plus = # vector addition
    a:
    b:
    {
      i = a.i + b.i;
      j = a.j + b.j;
    }
  ;
  scale = # vector scalar multiplication
    l:
    a:
    {
      i = l * a.i;
      j = l * a.j;
    }
  ;
  lambda = # list of coordinates
    let # four important points of the lambda skeleton
      torso = O;
      kopf = scale hals K;
      schwanz = scale 4 mK;
      fuss = scale 4 mJ;
    in
    [
      (plus (plus kopf J) (scale (thickness + gap) mK))
      (plus (plus kopf mJ) (scale (thickness + gap) mK))
      (plus torso (scale thickness mI))
      (plus fuss (scale thickness K))
      fuss
      (plus fuss (scale thickness I))
      (plus torso (scale thickness (plus mJ mK)))
      (plus schwanz (scale thickness mI))
      (plus schwanz (scale thickness I))
    ]
  ;
  sixthRotation = # rotate by n/6 * 2*pi, or n * 60degrees, but in terms of the lattice basis!
    n:
    latticePoint:
    if n == 0 then
      latticePoint
    else (
      sixthRotation
      (n - 1)
      {
        i = -latticePoint.j;
        j = latticePoint.i + latticePoint.j;
      }
    )
  ;
  allLambdas = builtins.genList
    (
      n:
      map
      (p: (sixthRotation n (plus (plus (scale 4 mJ) (scale (hals - 4) mJ)) p)))
      lambda
    )
    6
  ;
  sqrt3Over2 = 0.8660254037844386;
  shear = # basis transformation of (2*pi)/6 (or 60 degrees) lattice into cartesian coordinates
    latticePoint:
    {
      x = latticePoint.i + latticePoint.j * 0.5;
      y = -(latticePoint.j * sqrt3Over2); # minus because SVG has Y pointing downwards
    }
  ;
  allLambdasSheared = map (map shear) allLambdas;
  viewBox =
    let
      allPoints = builtins.concatLists allLambdasSheared;
      xs = map (p: p.x) allPoints;
      ys = map (p: p.y) allPoints;
      min = a: b: if a < b then a else b;
      max = a: b: if a < b then b else a;
      minX = builtins.foldl' min 0.0 xs;
      maxX = builtins.foldl' max 0.0 xs;
      minY = builtins.foldl' min 0.0 ys;
      maxY = builtins.foldl' max 0.0 ys;
    in
    "${toString (minX - pad)} ${toString (minY - pad)} ${toString (maxX - minX + 2 * pad)} ${toString (maxY - minY + 2 * pad)}"
  ;
  pointsToString = (
    points:
    builtins.concatStringsSep
    " "
    (map (p: "${toString p.x},${toString p.y}") points)
  );
  polygon = (
    { points, attrs }:
    let
      attrStr = (
        builtins.concatStringsSep
        " "
        (
          builtins.attrValues
          (builtins.mapAttrs (k: v: ''${k}="${v}"'') attrs)
        )
      );
    in
    ''<polygon points="${pointsToString points}" ${attrStr}/>''
  );
  svg = ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" width="${toString size}" height="${toString size}">
    ${
      builtins.concatStringsSep
      "\n"
      (
        builtins.genList
        (
          n:
          polygon {
            points = builtins.elemAt allLambdasSheared n;
            attrs = { fill = builtins.elemAt colors n; };
          }
        )
        6
      )
    }
    </svg>
  '';
in
assert builtins.length colors == 6;
# Assert that we have exact floats, in essence (but not as a type) integers:
assert builtins.all (p: p.i == builtins.floor p.i && p.j == builtins.floor p.j) lambda;
derivation {
  name = "nix-logo.svg";
  inherit system;
  builder = "/bin/sh";
  args = [ "-c" ''printf '%s' "$svgText" > "$out"'' ];
  svgText = svg;
}
