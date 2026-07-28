{
  description = "Nix package for Julia LanguageServer.jl";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
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
    devShells.${system}.default = pkgs.mkShell {
      packages = [julia julia-language-server];
    };
  };
}
