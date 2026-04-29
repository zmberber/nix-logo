{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
  outputs = {
    nixpkgs,
      ...
  }:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in
  {
    packages = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nix-logo = pkgs.callPackage ./packages/default.nix { };
      in
      {
        default = nix-logo;
        inherit nix-logo;
      }
    );
  };
}
