{
  description = "Minimal macOS CLI and dotfiles managed by standalone Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      home = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home/default.nix ./home/macos.nix ];
      };
    in {
      homeConfigurations.macbook = home;
      checks.${system}.home = home.activationPackage;
    };
}
