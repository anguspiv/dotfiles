# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io), shared across three machines.

```bash
chezmoi init --apply git@github.com:anguspiv/dotfiles.git
```

See [docs/CHEZMOI.md](docs/CHEZMOI.md) for machine profiles, package management, and how to make changes.

See [docs/REMOTE_ACCESS.md](docs/REMOTE_ACCESS.md) for reaching the Mini from the iPad and laptop over Tailscale with mosh.

Before committing any change, run:

```bash
./scripts/render-check.sh
```
