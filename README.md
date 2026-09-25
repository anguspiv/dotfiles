# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io), shared across three machines.

```bash
chezmoi init --apply git@github.com:anguspiv/dotfiles.git
```

See [docs/CHEZMOI.md](docs/CHEZMOI.md) for machine profiles, package management, and how to make changes.

Before committing any change, run:

```bash
./scripts/render-check.sh
```
