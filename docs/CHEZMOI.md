# Chezmoi

How this repository works: what the files mean, how a new machine gets built
from it, and what to run before you commit.

## 1. What this repo is

This repository **is** the chezmoi *source directory*. On a machine that has
been bootstrapped it lives at `~/.local/share/chezmoi`. Nothing here is read
directly by your shell or your editor — chezmoi renders these files and writes
the results into `$HOME`. Editing `~/.zshrc` by hand does not change this repo,
and `chezmoi apply` will overwrite it.

The filename encodes the target path and the file's attributes:

| Source name | Target | Meaning |
| --- | --- | --- |
| `dot_zshrc.tmpl` | `~/.zshrc` | `dot_` becomes a leading `.`; `.tmpl` is rendered as a Go template |
| `dot_config/ghostty/private_config` | `~/.config/ghostty/config` | `private_` makes the target mode `0600` |
| `dot_tmux/scripts/executable_foo.sh` | `~/.tmux/scripts/foo.sh` | `executable_` makes the target mode `0755` |
| `run_onchange_*` | (not a file) | A script executed during `chezmoi apply`, re-run whenever its *rendered* content changes |
| `run_once_*` | (not a file) | A script executed once per machine, on first apply |

Prefixes stack, so `dot_config/nvim/private_coc-settings.json` would deploy to
`~/.config/nvim/coc-settings.json` with mode `0600`.

Some paths in the source tree are deliberately **not** deployed. `.chezmoiignore`
excludes this repo's own tooling — `README.md`, `docs/`, `scripts/` — plus
secrets, shell history, and machine-local state. Without those entries chezmoi
would happily write `~/README.md` and `~/docs/` into the home directory.

Two directories are data rather than content:

- `.chezmoidata/` — YAML consumed by templates (`packages.yml`,
  `claude_plugins.yml`). Anything here is available as template data.
- `.githooks/` — this repo's git hooks, wired up via `core.hooksPath`.

## 2. Bootstrapping a new machine

Install chezmoi, then point it at this repo:

```bash
chezmoi init --apply git@github.com:anguspiv/dotfiles.git
```

That clones the repo into `~/.local/share/chezmoi`, renders
`.chezmoi.yaml.tmpl`, and applies everything in one pass. The `run_once_*` and
`run_onchange_*` scripts run as part of that apply, so packages, GPG signing and
the rest are set up without a second command.

On first init you are prompted for:

- **Identity** — full name, primary email, personal email, work email, and a GPG
  signing key ID (all the email prompts accept an empty value).
- **Machine** — `machine.type` (the profile, see below) and
  `machine.performance` (`high`, `medium`, `low`, `handheld`).
- **Feature flags** — booleans for AI tools, development tools, git tools,
  kubernetes and docker. Templates gate optional configuration on these.
- **Work credentials and hosts** — API tokens and host URLs used by work
  tooling. Every one of these accepts an empty value; on a personal machine,
  press Enter through them.

Answers are written to `~/.config/chezmoi/chezmoi.yaml`. That file lives
**outside** this repository and is never committed — it is per-machine state.
All the prompts use the `promptOnce` family, so re-running `chezmoi init` will
not re-ask anything already answered. To change an answer, edit
`~/.config/chezmoi/chezmoi.yaml` directly and re-apply.

## 3. Machine profiles

`machine.type` is the single switch that distinguishes the machines this repo is
shared across. Templates branch on it:

```
{{ if eq .machine.type "work" }}...{{ end }}
```

The intended set of values is:

| Profile | For | Includes |
| --- | --- | --- |
| `work` | The employer-managed laptop | Everything in `personal`, plus work-only shell configuration, work tooling and the work git identity |
| `personal` | Personally owned development machines | The full development environment: editors, language toolchains, containers, kubernetes tooling |
| `light` | Servers and low-touch boxes | Shell, git, tmux and core CLI only — no GUI applications, no heavy toolchains |

The value lives in `~/.config/chezmoi/chezmoi.yaml`, not in the repo, so each
machine picks its own without any per-machine branch or file.

> **Status:** these three values are being migrated to. `.chezmoi.yaml.tmpl`
> still prompts with the older set — `development`, `server`, `minimal`,
> `steamos` — while `scripts/render-check.sh` already validates against
> `light`/`personal`/`work`, and `dot_zshrc.tmpl` already branches on
> `work`. The prompt list is updated as part of the profile work; until then,
> treat the table above as the target, not as what `chezmoi init` currently
> offers.

## 4. Package management

Packages are declared as data, in `.chezmoidata/packages.yml`:

```yaml
packages:
  darwin:
    taps:   [...]   # third-party Homebrew taps
    brews:  [...]   # formulae
    casks:  [...]   # GUI applications
    mas:    [...]   # Mac App Store apps, as {name, id}
```

`run_onchange_darwin-install-packages.sh.tmpl` turns that data into a Homebrew
bundle and pipes it straight to Homebrew:

```bash
brew bundle --file=/dev/stdin <<EOF
...generated from .chezmoidata/packages.yml...
EOF
```

**There is no Brewfile.** Nothing in this repo reads a `Brewfile`, and none is
deployed. The bundle exists only for the lifetime of that one command, on
stdin. `packages.yml` is the only package manifest — to add or remove a package,
edit it and run `chezmoi apply`.

Because the script is `run_onchange_`, chezmoi re-runs it whenever the rendered
bundle changes — that is, whenever you edit `packages.yml` — and skips it
otherwise. The script also `brew tap`s and `brew trust`s third-party formulae
first, because Homebrew refuses to load formulae from untrusted taps and that
trust is local machine state chezmoi does not manage.

The whole script is guarded by `{{ if eq .chezmoi.os "darwin" }}`, so it renders
to nothing on Linux.

## 5. Making changes

Work through chezmoi, not through `$HOME`.

```bash
# Bring an existing file under management
chezmoi add ~/.config/foo/config

# Edit a managed file (opens the source file, template and all)
chezmoi edit ~/.zshrc

# See exactly what would change in $HOME, and nothing else
chezmoi diff

# Write the changes out
chezmoi apply
```

`chezmoi add` copies the file as-is; if it needs to differ between machines,
rename the source file to end in `.tmpl` and add the template branches by hand.

Then commit. `chezmoi cd` drops you into the source directory:

```bash
chezmoi cd
./scripts/render-check.sh     # see section 6 - run this first
git add <files>
git commit -m "..."
exit
```

`~/.local/bin/chezmoi-sync` wraps the pull/commit/push cycle if you prefer one
command, and `chezmoi-auto-commit` generates a commit message from the diff.

## 6. Verification

**Run `./scripts/render-check.sh` before every commit.** It is the closest
thing this repo has to a test suite, and it is cheap.

```
$ ./scripts/render-check.sh

checked 39 template renders across 3 profiles
checked 27 rendered shell script(s) with bash -n
OK: all templates render and all rendered shell scripts parse, for all profiles
```

It makes two passes over every `*.tmpl` in the tree:

1. **Render.** Each template is rendered against a synthetic config for each of
   the three profiles (`light`, `personal`, `work`). This catches the failure
   mode that matters most here: a template that references data defined only for
   the profile you happen to be sitting at renders fine on your machine and
   breaks on the next one. Failures print as `FAIL [profile] path`.

2. **Parse.** Every rendered `*.sh.tmpl` is fed to `bash -n`. "It rendered" is
   not "it works" — an edit that dropped an `if` branch but left its `fi` behind
   rendered perfectly and still emitted bash with a syntax error. That bug was
   caught by this pass. Since `run_once_*` and `run_onchange_*` scripts execute
   during `chezmoi apply` on a fresh machine, a syntax error there breaks the
   very rebuild this repo exists to enable. Failures print as
   `SHELL FAIL [profile] path`.

Pass 2 is scoped to `*.sh.tmpl` on purpose: `dot_zshrc.tmpl` and
`dot_zshenv.tmpl` are zsh, and `dot_gitconfig.tmpl` is not shell at all, so
running `bash -n` over them would only manufacture false failures. A template
that renders to nothing for a given profile (an OS guard, for instance) is a
pass — `bash -n` on empty input succeeds.

`.chezmoi.yaml.tmpl` is excluded from both passes, because its `prompt*Once`
calls need interactive input that exists only during `chezmoi init`.

The script exits non-zero if anything fails, or if it finds no templates at all.

## 7. The post-commit hook

`.githooks/post-commit` is wired in via `core.hooksPath` and pushes
automatically **only when the current branch is `main`**, a remote named
`origin` exists, and `HEAD` resolves. On any other branch it prints
`Skipping push` and does nothing — so feature branches such as this one stay
local until you push them yourself.

If you cloned this repo fresh and the hook is not running, set it up:

```bash
git config core.hooksPath .githooks
```

## Further reading

- chezmoi user guide — <https://chezmoi.io/user-guide/>
- Templating reference — <https://chezmoi.io/user-guide/templating/>
- `chezmoi data` — dump the template data available on this machine
- `chezmoi execute-template < file.tmpl` — render a single template ad hoc
