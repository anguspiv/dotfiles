# Claude Code plugins

## How this is synced

Claude Code reads two keys from `~/.claude/settings.json`:

- `extraKnownMarketplaces` — catalogues to know about
- `enabledPlugins` — which plugins are on

On a machine where a declared marketplace is not on disk, Claude Code clones it
and downloads the enabled plugins that are not cached yet, at session start.
That is the whole sync mechanism. It is native, and it auto-updates.

So chezmoi only has to own those two keys:

```
.chezmoidata/claude_plugins.yml                     # the declaration
private_dot_claude/modify_private_settings.json.tmpl # merges it into settings.json
```

A `modify_` script rather than a managed file, because Claude Code writes
`settings.json` at runtime — model, theme, `claude plugin marketplace add`. The
script takes the live file on stdin and emits the merged result, so every key
chezmoi does not declare survives untouched.

It **merges, never prunes**: declared entries win, undeclared ones are left
alone. Same rule as `brew bundle` here. Removing a plugin is a deliberate
`claude plugin uninstall`, not a side effect of editing YAML.

`.chezmoiignore` excludes `.claude/*` and re-includes only `settings.json`. Note
`.claude/*` and not `.claude/` — an ignored *directory* cannot have a child
re-included, the same rule gitignore has.

## What replaced, and why

This previously tracked individual skill names in `claude_skills.yml` and shelled
out to `claude plugin install <skill-name>` from a 400-line script. That was
wrong in three ways, all of which stayed hidden until a fresh clone ran it:

1. **Skills are not the unit of installation; plugins are.** There is no
   per-skill plugin to install. Every entry naming a skill rather than a plugin
   failed with `not found in any configured marketplace`.
2. **Two mechanisms were conflated.** `npx skills add` (third-party,
   `vercel-labs/skills`) installs standalone skills into `~/.claude/skills/` and
   records them in `~/.agents/.skill-lock.json`. `claude plugin install`
   (first-party) installs plugins into `~/.claude/plugins/`. The script verified
   with the first and installed with the second, so plugin-provided skills
   reported "installed" and "failed" on the same run.
3. **It reimplemented something Claude Code already does**, and could only ever
   do it worse.

## Choosing what to enable

Every auto-invocable skill a plugin brings puts its name and description in
context on **every turn**, not only when used. A bundle is therefore not free.

`example-skills` from `anthropics/skills` is the worked example: it bundles 12
skills, of which 5 were wanted. It is deliberately not enabled. If one of its
skills is needed later, install that skill standalone rather than paying
per-turn context for 12 to get 1.

Prefer, in order: a narrow plugin, a standalone skill in `~/.claude/skills/`,
then a broad bundle.

## Plugin skills are namespaced

A plugin's skills are invoked as `/<plugin>:<skill>`, using the plugin's
*manifest* name. A standalone skill of the same name is invoked bare. Moving a
skill from standalone to plugin therefore changes how it is called —
`/brainstorming` becomes `/superpowers:brainstorming`. Check that before
swapping one for the other.
