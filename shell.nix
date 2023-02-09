let
  pkgs =
    import
      (
        fetchTarball (
          builtins.fromJSON (
            builtins.readFile ./nixpkgs.json
          )
        )
      )
      { };
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
