{
  description = "Nix package for Julia LanguageServer.jl";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    julia-language-server = pkgs.writeShellApplication {
      name = "julia-language-server";
      runtimeInputs = [pkgs.julia];
      text = ''
        exec julia --project=${./.} -e 'using LanguageServer; runserver()'
      '';
    };
  in {
    formatter.${system} = pkgs.alejandra;
    packages.${system} = {
      default = julia-language-server;
      inherit julia-language-server;
    };
    devShells.${system}.default = pkgs.mkShell {
      packages = [pkgs.julia julia-language-server];
    };
  };
}
