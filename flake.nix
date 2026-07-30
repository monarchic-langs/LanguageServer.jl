{
  description = "Nix package for Julia LanguageServer.jl";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    julia = pkgs.julia.withPackages ["LanguageServer"];
    julia-language-server = pkgs.writeShellApplication {
      name = "julia-language-server";
      runtimeInputs = [julia];
      text = ''
        exec julia -e 'using LanguageServer; runserver()' "$@"
      '';
    };
  in {
    formatter.${system} = pkgs.alejandra;
    packages.${system} = {
      default = julia-language-server;
      inherit julia-language-server;
    };
    checks = {
      ${system} = {
        inherit (self.packages.${system}) default;

        flake-format =
          pkgs.runCommand "julia-language-server-flake-format-check"
          {nativeBuildInputs = [pkgs.alejandra];}
          ''
            alejandra --check ${./flake.nix}
            touch $out
          '';

        language-server-smoke =
          pkgs.runCommand "julia-language-server-smoke"
          {nativeBuildInputs = [julia];}
          ''
            julia -e 'using LanguageServer; println("LanguageServer loaded")'
            touch $out
          '';
      };
    };
    devShells.${system}.default = pkgs.mkShell {
      packages = [julia julia-language-server];
    };
  };
}
