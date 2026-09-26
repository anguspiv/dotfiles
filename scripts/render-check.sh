#!/usr/bin/env bash
# Renders every chezmoi template against every machine profile, then checks
# that every rendered shell script is syntactically valid shell.
# Exits non-zero if any template fails to render OR any rendered shell script
# fails to parse.
#
# This is the closest thing this repo has to a test suite: a template that
# references a variable only defined for one profile will render fine on the
# machine you are sitting at and break on another. This catches that.
#
# Pass 2 exists because "it rendered" is not "it works". An edit that removed
# an if-branch from run_once_setup-gpg-keys.sh.tmpl but left its closing `fi`
# behind rendered perfectly and still produced bash with a syntax error. Since
# run_once_*/run_onchange_* scripts execute during `chezmoi apply` on a fresh
# machine, that would have broken the very rebuild this repo exists to enable.
# Rendering the template proves the Go template is well formed; only running
# `bash -n` over the result proves the shell it emitted is well formed too.
#
# The profile list and the synthetic config below are deliberately
# forward-looking: they describe the light/personal/work machine profiles this
# repo is being reshaped towards, not the machine.type values .chezmoi.yaml.tmpl
# currently offers. That is intentional. The legacy steamos profile is omitted
# because its templates are slated for deletion, and data keys the config does
# not emit yet (work.bulkworkspace) are included so templates can start
# consuming them. As the cleanup lands, config and harness converge.

set -uo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROFILES=("light" "personal" "work")
TMPDIR_="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_"' EXIT

failures=0
checked=0
shell_failures=0
shell_checked=0

for profile in "${PROFILES[@]}"; do
  cfg="$TMPDIR_/$profile.yaml"

  # signing.sshPublicKey is per-machine: non-empty selects SSH commit signing,
  # empty keeps GPG. Set it for exactly one profile so a single run renders both
  # branches of the signing conditionals in dot_gitconfig.tmpl and
  # dot_config/git/allowed_signers.tmpl. The key below is a throwaway generated
  # for this fixture; nothing signs with it.
  if [ "$profile" = "light" ]; then
    ssh_signing_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIITUufBHZ7i3PitPpA5BsOHA8XdEuxnpY3mDA53mnqij render-check@example.invalid"
  else
    ssh_signing_key=""
  fi

  # auth.sshPublicKey is the separate per-machine key that pins github.com to
  # this host's identity (see private_dot_ssh/). Independent of the signing key
  # above, so set it on a DIFFERENT profile: that way one run renders every
  # combination of (signing set/unset) x (auth set/unset) rather than only the
  # two diagonal cases. Throwaway fixture key; nothing authenticates with it.
  if [ "$profile" = "personal" ]; then
    ssh_auth_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCUYFvgFe1B/xWnIngZydGEILzI4iTj1dfnTEwHaCpf render-check@example.invalid"
  else
    ssh_auth_key=""
  fi

  cat > "$cfg" <<YAML
data:
  configVersion: 1
  name: "Render Check"
  email: "render-check@example.invalid"
  personalEmail: "personal@example.invalid"
  workEmail: "work@example.invalid"
  signingkey: "0000000000000000"
  machine:
    type: "$profile"
    performance: "high"
  features:
    ai_tools: true
    development_tools: true
    git_tools: true
    kubernetes: true
    docker: true
  secrets:
    write_token: ""
    gl_token: ""
    jira_token: ""
    figma_token: ""
    confluence_token: ""
    confluence_host: "https://confluence.example.invalid"
    confluence_username: ""
    gitlab_host: "gitlab.example.invalid"
    work_api_key: ""
    work_db_url: ""
    work_slack_token: ""
  work:
    bulkworkspace: "/tmp/workspace"
  signing:
    sshPublicKey: "$ssh_signing_key"
  auth:
    sshPublicKey: "$ssh_auth_key"
  editor: "zed"
  visual: "zed"
  shell: "zsh"
  terminal: "ghostty"
  development:
    languages: ["javascript", "typescript", "python", "lua", "bash"]
    frameworks: ["react", "vue", "node"]
    tools: ["docker", "git", "tmux"]
YAML

  # .chezmoi.yaml.tmpl is excluded from the find below because it is the config
  # generator itself: its promptStringOnce/promptChoiceOnce calls require
  # interactive input that only exists during `chezmoi init`, so it can never
  # render here.
  while IFS= read -r tmpl; do
    checked=$((checked + 1))

    # Pass 1: the template must render. The rendered text is kept (rather than
    # thrown at /dev/null) so pass 2 can inspect it.
    out="$TMPDIR_/$(basename "$tmpl").$profile.rendered"
    if chezmoi --config "$cfg" --source "$SRC" execute-template < "$tmpl" > "$out" 2> "$out.err"; then
      rendered=1
    else
      rendered=0
      echo "FAIL [$profile] $tmpl"
      sed 's/^/     /' "$out.err"
      failures=$((failures + 1))
    fi

    # Pass 2: if the rendered output is a shell script, it must also be valid
    # shell. Scoped to *.sh.tmpl (which covers every run_once_*/run_onchange_*
    # script plus cleanup-chezmoi.sh.tmpl) because those are the templates that
    # render to bash. dot_gitconfig.tmpl, the *.json.tmpl files and friends are
    # not shell at all, and dot_zshrc.tmpl/dot_zshenv.tmpl are zsh, not bash -
    # feeding any of them to `bash -n` would only manufacture false failures.
    #
    # A template guarded entirely by e.g. {{ if eq .chezmoi.os "darwin" }} can
    # render to nothing for a non-matching profile. `bash -n` on empty input
    # succeeds, so an empty render is correctly treated as a pass.
    case "$tmpl" in
      *.sh.tmpl)
        if [ "$rendered" -eq 1 ]; then
          shell_checked=$((shell_checked + 1))
          if ! syntax_err=$(bash -n "$out" 2>&1); then
            echo "SHELL FAIL [$profile] $tmpl"
            echo "$syntax_err" | sed 's/^/     /'
            shell_failures=$((shell_failures + 1))
          fi
        fi
        ;;
    esac
  done < <(find "$SRC" -name '*.tmpl' -not -path '*/.git/*' -not -name '.chezmoi.yaml.tmpl' | sort)
done

echo
echo "checked $checked template renders across ${#PROFILES[@]} profiles"
echo "checked $shell_checked rendered shell script(s) with bash -n"

status=0
if [ "$failures" -gt 0 ]; then
  echo "FAILED: $failures render error(s)"
  status=1
fi
if [ "$shell_failures" -gt 0 ]; then
  echo "FAILED: $shell_failures shell syntax error(s)"
  status=1
fi
if [ "$checked" -eq 0 ]; then
  echo "FAILED: no templates found under $SRC - check SRC is correct"
  status=1
fi
if [ "$status" -ne 0 ]; then
  exit "$status"
fi
echo "OK: all templates render and all rendered shell scripts parse, for all profiles"
