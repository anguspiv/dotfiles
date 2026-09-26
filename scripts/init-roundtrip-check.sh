#!/usr/bin/env bash
# Proves `chezmoi init` converges: a second init must ask nothing.
#
# promptStringOnce and friends read a previously stored answer back out of the
# config's data: block. A prompt whose value is never written there can never be
# satisfied, so every init re-asks. That shipped - work_api_key, work_db_url and
# work_slack_token were collected and discarded for as long as they existed, and
# it only surfaced when someone ran init a second time on a real machine.
#
# manifest-check.sh catches this statically by comparing prompt variables to the
# data: block. This catches it dynamically, and also catches the cases static
# analysis cannot see: a prompt whose stored value fails to satisfy it (a
# promptChoiceOnce whose stored answer is not in its own choice list, which is
# what a stale machine.type of "development" did).
#
# Prompt text is scraped from the template rather than hardcoded, because
# chezmoi keys --promptString by the PROMPT TEXT and not by the variable path.
# Hardcoding would silently rot the moment someone reworded a question.

set -uo pipefail

# Both inits run with stdin closed: --no-tty makes chezmoi fall back to reading
# stdin, and an inherited stdin that never closes blocks forever rather than
# erroring. /dev/null gives it an immediate EOF, which is the failure we want.
# `timeout` is a belt-and-braces bound for CI; macOS ships no timeout(1), so it
# is optional rather than required.
if command -v timeout >/dev/null 2>&1; then RUN=(timeout 120)
elif command -v gtimeout >/dev/null 2>&1; then RUN=(gtimeout 120)
else RUN=(); fi

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR_="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_"' EXIT

CONFIG_TMPL="$SRC/.chezmoi.yaml.tmpl"
[ -f "$CONFIG_TMPL" ] || { echo "OK: no .chezmoi.yaml.tmpl to check"; exit 0; }

# Full isolation matters more than it looks. --config-path only says where the
# generated config is WRITTEN; chezmoi still READS the real ~/.config/chezmoi
# one, so without a scratch HOME the test inherits this machine's answers and
# silently passes every prompt it should have been testing. Copy the source too
# (minus .git, so chezmoi does not touch the real repo), because init operates
# on the source directory.
FAKE_HOME="$TMPDIR_/home"
SRC_COPY="$TMPDIR_/src"
mkdir -p "$FAKE_HOME" "$SRC_COPY"
tar -C "$SRC" --exclude='./.git' -cf - . | tar -C "$SRC_COPY" -xf -

CFG="$FAKE_HOME/.config/chezmoi/chezmoi.yaml"
args=()

# promptStringOnce . "key" "Prompt text" [default]  -> answer with empty string
while IFS= read -r text; do
  [ -n "$text" ] || continue
  case "$text" in *=*) echo "FAILED: prompt text contains '=', which breaks key=value flags: $text"; exit 1 ;; esac
  args+=(--promptString "$text=")
done < <(grep -oE 'promptStringOnce[^"]*"[^"]*"[[:space:]]*"[^"]*"' "$CONFIG_TMPL" \
         | sed -E 's/.*"[^"]*"[[:space:]]*"([^"]*)"$/\1/' | sort -u)

# promptBoolOnce . "key" "Prompt text" -> answer false
while IFS= read -r text; do
  [ -n "$text" ] || continue
  args+=(--promptBool "$text=false")
done < <(grep -oE 'promptBoolOnce[^"]*"[^"]*"[[:space:]]*"[^"]*"' "$CONFIG_TMPL" \
         | sed -E 's/.*"[^"]*"[[:space:]]*"([^"]*)"$/\1/' | sort -u)

# promptChoiceOnce . "key" "Prompt text" (list "a" "b") -> answer with the first
# choice, so the answer is guaranteed valid for that prompt's own list.
while IFS= read -r line; do
  [ -n "$line" ] || continue
  # Anchored at ^promptChoiceOnce and using [^"]* rather than .* so the match
  # cannot run past the prompt text into the (list "a" "b") that follows. A
  # greedy .* here captured a CHOICE VALUE as the prompt text, which matched no
  # real prompt, and chezmoi then blocked on its picker despite --no-tty.
  text=$(printf '%s' "$line" | sed -E 's/^promptChoiceOnce[^"]*"[^"]*"[[:space:]]*"([^"]*)".*/\1/')
  first=$(printf '%s' "$line" | sed -E 's/.*\(list[[:space:]]*"([^"]*)".*/\1/')
  args+=(--promptChoice "$text=$first")
done < <(grep -oE 'promptChoiceOnce[^)]*\)' "$CONFIG_TMPL" | sort -u)

echo "supplying ${#args[@]} prompt flag token(s) to the first init"

# Pass 1: answer everything. This must succeed.
if ! "${RUN[@]}" env HOME="$FAKE_HOME" chezmoi init --no-tty --source "$SRC_COPY" "${args[@]}" \
      < /dev/null > "$TMPDIR_/init1.out" 2>&1; then
  echo "FAILED: first init errored even with every prompt supplied"
  sed 's/^/     /' "$TMPDIR_/init1.out"
  exit 1
fi
[ -f "$CFG" ] || { echo "FAILED: first init wrote no config to $CFG"; exit 1; }

# Pass 2: answer NOTHING. Every prompt must be satisfied from the config
# written by pass 1. Any prompt reached here is one that was never persisted.
if ! "${RUN[@]}" env HOME="$FAKE_HOME" chezmoi init --no-tty --source "$SRC_COPY" \
      < /dev/null > "$TMPDIR_/init2.out" 2>&1; then
  echo "FAILED: second init re-prompted, so at least one answer was not persisted"
  echo "        (chezmoi init would ask this question again on every run)"
  sed 's/^/     /' "$TMPDIR_/init2.out"
  exit 1
fi

echo "OK: chezmoi init converges - a second init asks nothing"
