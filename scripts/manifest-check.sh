#!/usr/bin/env bash
# Cross-reference checks over the declaration files.
#
# render-check.sh proves each template renders and each rendered script parses.
# It cannot catch a declaration that disagrees with its CONSUMER, because both
# files are individually valid. Every defect found when this repo was first
# cloned onto a machine with no pre-existing state was of that kind:
#
#   - `qmk` was declared bare while its formula lives in the qmk/qmk tap, so the
#     trust loop's */*/* pattern never matched it and brew refused to load it.
#   - dbcli/tap was declared while nothing used it, so Homebrew warned about an
#     untrusted tap on every invocation for no benefit.
#   - Three prompts were collected by .chezmoi.yaml.tmpl and never written to
#     its data: block, so promptStringOnce could never find them and every
#     `chezmoi init` re-prompted forever.
#   - Skills were declared by skill name when the installable unit is a plugin,
#     so all nine failed with "not found in any configured marketplace".
#
# Each check below exists because one of those shipped. They are pure data
# comparisons: no network, no Homebrew, no Claude Code.

set -uo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMPDIR_="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_"' EXIT

CFG="$TMPDIR_/min.yaml"
printf 'data:\n  machine:\n    type: "personal"\n' > "$CFG"

DATA="$TMPDIR_/data.json"
if ! chezmoi --config "$CFG" --source "$SRC" data --format json > "$DATA" 2>"$TMPDIR_/err"; then
  echo "FAILED: could not read chezmoi data"
  sed 's/^/     /' "$TMPDIR_/err"
  exit 1
fi

failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }

# --- 1. every declared tap is used by a fully-qualified formula ----------------
# A tap earns its place only if some formula names it. A tap with no
# fully-qualified user is either dead weight (untap it) or, worse, has a formula
# declared bare - which is how `qmk` got past the trust loop and broke apply.
for profile in light personal work; do
  taps=$(jq -r --arg p "$profile" '
    ((.packages.darwin.core.taps // []) + (.packages.darwin[$p].taps // []))[]' "$DATA" 2>/dev/null | sort -u)
  brews=$(jq -r --arg p "$profile" '
    ((.packages.darwin.core.brews // []) + (.packages.darwin[$p].brews // []))[]' "$DATA" 2>/dev/null)
  for tap in $taps; do
    if ! printf '%s\n' "$brews" | grep -q "^${tap}/"; then
      fail "[$profile] tap '$tap' is declared but no formula is qualified as '${tap}/<formula>'." \
           "Either drop the tap, or write the formula that needs it fully qualified" \
           "so the brew-trust loop can match it."
    fi
  done
done

# --- 2. every prompt is persisted into the config's data: block ---------------
# promptXOnce reads the value back from config data. A prompt whose variable is
# never emitted there can never be satisfied, so init re-prompts on every run.
CONFIG_TMPL="$SRC/.chezmoi.yaml.tmpl"
if [ -f "$CONFIG_TMPL" ]; then
  data_block=$(sed -n '/^data:$/,$p' "$CONFIG_TMPL")
  while IFS= read -r var; do
    [ -n "$var" ] || continue
    # Pattern built by concatenation so the shell cannot eat the literal '$',
    # and with an explicit trailing boundary so $docker does not match
    # $dockerCompose.
    if ! printf '%s' "$data_block" | grep -qE '\$'"$var"'([^A-Za-z0-9_]|$)'; then
      fail ".chezmoi.yaml.tmpl prompts into '\$$var' but never writes it to the data: block." \
           "promptXOnce will never find the stored value, so chezmoi init re-prompts forever."
    fi
  done < <(grep -oE '\$[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:=[[:space:]]*prompt[A-Za-z]*Once' "$CONFIG_TMPL" \
           | sed -E 's/^\$([A-Za-z_][A-Za-z0-9_]*).*/\1/' | sort -u)
fi

# --- 3. every enabled plugin resolves to a known marketplace ------------------
# claude-plugins-official is exempt: Claude Code adds it itself on first start.
known=$(jq -r '(.claude_plugins.marketplaces // {}) | keys[]' "$DATA" 2>/dev/null)
known="$known
claude-plugins-official"
while IFS= read -r id; do
  [ -n "$id" ] || continue
  case "$id" in
    *@*) market="${id##*@}" ;;
    *)   fail "plugin '$id' has no '@marketplace' suffix." \
              "Plugins are installed as <plugin>@<marketplace>; a bare name is a skill name," \
              "and there is no per-skill plugin to install."
         continue ;;
  esac
  printf '%s\n' "$known" | grep -qx "$market" || \
    fail "plugin '$id' names marketplace '$market', which is not in claude_plugins.marketplaces."
done < <(jq -r '(.claude_plugins.enabled // {}) | keys[]' "$DATA" 2>/dev/null)

# --- 4. every declared marketplace is used ------------------------------------
enabled_ids=$(jq -r '(.claude_plugins.enabled // {}) | keys[]' "$DATA" 2>/dev/null)
while IFS= read -r market; do
  [ -n "$market" ] || continue
  printf '%s\n' "$enabled_ids" | grep -q "@${market}\$" || \
    fail "marketplace '$market' is declared but no enabled plugin comes from it."
done < <(jq -r '(.claude_plugins.marketplaces // {}) | keys[]' "$DATA" 2>/dev/null)

echo
if [ "$failures" -gt 0 ]; then
  echo "FAILED: $failures manifest inconsistency/ies"
  exit 1
fi
echo "OK: taps, prompts, plugins and marketplaces are mutually consistent"
