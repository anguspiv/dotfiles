#!/usr/bin/env bash
# Renders every chezmoi template against every machine profile.
# Exits non-zero if any template fails to render.
#
# This is the closest thing this repo has to a test suite: a template that
# references a variable only defined for one profile will render fine on the
# machine you are sitting at and break on another. This catches that.
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

for profile in "${PROFILES[@]}"; do
  cfg="$TMPDIR_/$profile.yaml"
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
    if ! err=$(chezmoi --config "$cfg" --source "$SRC" execute-template < "$tmpl" 2>&1 >/dev/null); then
      echo "FAIL [$profile] $tmpl"
      echo "     $err"
      failures=$((failures + 1))
    fi
  done < <(find "$SRC" -name '*.tmpl' -not -path '*/.git/*' -not -name '.chezmoi.yaml.tmpl' | sort)
done

echo
echo "checked $checked template renders across ${#PROFILES[@]} profiles"
if [ "$failures" -gt 0 ]; then
  echo "FAILED: $failures render error(s)"
  exit 1
fi
if [ "$checked" -eq 0 ]; then
  echo "FAILED: no templates found under $SRC - check SRC is correct"
  exit 1
fi
echo "OK: all templates render for all profiles"
