### Deployment

After making changes to the standalone flake:
1. git push origin
2. switch to the NixOS directory
3. `nix flake update`
4. `sudo nixos-rebuild switch --flake ".#system-name"

