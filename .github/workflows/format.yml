name: Format Nix with Alejandra

on:
  push:
    paths:
      - "**.nix"
  workflow_dispatch:

jobs:
  format:
    name: Format Nix files

    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Set Git user info
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"

      - name: Install Nix
        uses: cachix/install-nix-action@v25

      - name: Install Alejandra
        run: |
          nix run nixpkgs#alejandra .

      - name: Commit changes
        run: |
          if ! git diff --quiet; then
            git commit -am "style: format nix files with Alejandra"
            git push
          fi
