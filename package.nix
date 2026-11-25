{
  system,
  size ? 1024,
  gap ? 0,
  thickness ? 1,
  colors ? [ "#5277C3" "#7EBAE4" "#5277C3" "#7EBAE4" "#5277C3" "#7EBAE4" ],
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
  sqrt3Over2 = 0.8660254037844386;
  O = { i = 0; j = 0; };
  I = { i = 1; j = 0; };
  J = { i = 0; j = 1; };
  K = { i = -1; j = 1; };
  mI = { i = -1; j = 0; };
  mJ = { i = 0; j = -1; };
  mK = { i = 1; j = -1; };
  shear =
    latticePoint:
    {
      x = latticePoint.i + latticePoint.j * 0.5;
      y = -(latticePoint.j * sqrt3Over2);
    }
  ;
  addLatticePoints =
    a:
    b:
    {
      i = a.i + b.i;
      j = a.j + b.j;
    }
  ;
  scaleLatticePoint =
    l:
    a:
    {
      i = l * a.i;
      j = l * a.j;
    }
  ;
  sixthRotation =
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
  lambda =
    let
      torso = O;
      kopf = scaleLatticePoint 4 K;
      schwanz = scaleLatticePoint 4 mK;
      fuss = scaleLatticePoint 4 mJ;
    in
    [
      (addLatticePoints (addLatticePoints kopf J) (scaleLatticePoint (thickness + gap) mK))
      (addLatticePoints (addLatticePoints kopf mJ) (scaleLatticePoint (thickness + gap) mK))
      (addLatticePoints torso (scaleLatticePoint thickness mI))
      (addLatticePoints fuss (scaleLatticePoint thickness K))
      fuss
      (addLatticePoints fuss (scaleLatticePoint thickness I))
      (addLatticePoints torso (scaleLatticePoint thickness (addLatticePoints mJ mK)))
      (addLatticePoints schwanz (scaleLatticePoint thickness mI))
      (addLatticePoints schwanz (scaleLatticePoint thickness I))
    ]
  ;
  allLambdas = builtins.genList
    (
      n:
      map
      (p: (sixthRotation n (addLatticePoints (scaleLatticePoint 4 mJ) p)))
      lambda
    )
    6
  ;
  allLambdasSheared = map (map shear) allLambdas;
  viewBox =
    let
      allPoints = builtins.concatLists allLambdasSheared;
      xs = map (p: p.x) allPoints;
      ys = map (p: p.y) allPoints;
      min = a: b: if a < b then a else b;
      max = a: b: if a < b then b else a;
      minX = builtins.foldl' min (builtins.head xs) xs;
      maxX = builtins.foldl' max (builtins.head xs) xs;
      minY = builtins.foldl' min (builtins.head ys) ys;
      maxY = builtins.foldl' max (builtins.head ys) ys;
      pad = 1;
    in
    "${toString (minX - pad)} ${toString (minY - pad)} ${toString (maxX - minX + 2 * pad)} ${toString (maxY - minY + 2 * pad)}"
  ;
  svg = builtins.concatStringsSep "\n" (
    [''<svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" width="${toString size}" height="${toString size}">'']
    ++
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
    ++
    [''</svg>'']
  );
in
derivation {
  name = "nix-logo.svg";
  inherit system;
  builder = "/bin/sh";
  args = [ "-c" ''printf '%s' "$svg" > "$out"'' ];
  inherit svg;
}
