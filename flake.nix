{
  description = "rloop-bash: the Bash Implementation of rloop";

  # The same nixpkgs revision the specification pins (spec/flake.nix).
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/aff8a0b28396750446e5537a96461bc4facdb287";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAll (pkgs: {
        default = pkgs.writeShellApplication {
          name = "rloop";
          # The script keeps its own `set -u`; errexit would fight a loop that inspects exit codes.
          bashOptions = [ "nounset" ];
          # git, coreutils and util-linux (uuidgen) are appended, not prepended: whatever the
          # caller has first on PATH — its own git, its own agent CLIs — must win.
          text = ''
            export PATH="$PATH:${pkgs.lib.makeBinPath [ pkgs.git pkgs.coreutils pkgs.util-linux ]}"
          '' + builtins.readFile ./bin/rloop;
        };
        rloop = self.packages.${pkgs.system}.default;
      });
    };
}
