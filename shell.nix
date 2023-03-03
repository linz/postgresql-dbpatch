let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  packages = [
    pkgs.cacert
    pkgs.cargo
    pkgs.docker
    pkgs.gitFull
    pkgs.nodejs
    (
      pkgs.postgresql.withPackages (
        ps: [
          ps.pgtap
        ]
      )
    )
    pkgs.perlPackages.TAPParserSourceHandlerpgTAP
    pkgs.pre-commit
    pkgs.which
  ];
}
