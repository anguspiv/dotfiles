# Claude Code Skills Audit & Sync Strategy

## Overview

This document describes the strategy for syncing Claude Code skills across multiple machines using chezmoi.

**Total Skills**: 107 currently installed
**Strategy**: Track skill names in YAML manifest → Auto-install via chezmoi script → Skills downloaded to `~/.agents/skills/`

## Why This Approach

1. **Lightweight**: Only track skill names (~5KB YAML) instead of 17MB of skill directories
2. **Declarative**: YAML defines desired state on each machine
3. **Automated**: Script installs missing skills via `claude plugin install`
4. **Extensible**: Easy to add work-specific skills later
5. **Handles Broken Skills**: Will attempt to reinstall skills with empty hashes

## Architecture

```
chezmoi source directory:
├── .chezmoidata/
│   └── claude-skills.yml          # All 107 current skills + future work skills
├── run_onchange_after_claude-sync-skills.sh.tmpl  # Auto-install script
└── docs/
    └── CLAUDE_SKILLS_AUDIT.md     # This audit document
```

## Skills by Source

### obra/superpowers (14 skills)
Development workflow and best practices
- systematic-debugging
- writing-plans
- test-driven-development
- executing-plans
- using-superpowers
- using-git-worktrees
- requesting-code-review
- brainstorming
- dispatching-parallel-agents
- finishing-a-development-branch
- receiving-code-review
- subagent-driven-development
- verification-before-completion
- writing-skills

### anthropics/skills (13 skills)
Official Anthropic skills including document handling
- frontend-design
- skill-creator
- mcp-builder
- pdf, pptx, xlsx, docx
- webapp-testing
- internal-comms
- doc-coauthoring
- canvas-design
- slack-gif-creator

### github/awesome-copilot (23 skills)
Comprehensive development tooling
- Epic/Feature breakdown tools
- Git commit automation
- Playwright testing tools
- Refactoring utilities
- README/documentation generators

### antfu/skills (7 skills)
Vite ecosystem and modern tooling
- turborepo, pnpm, vitest, vite, vitepress
- web-design-guidelines
- slidev

### kepano/obsidian-skills (5 skills)
Obsidian PKM integration
- defuddle, obsidian-markdown, obsidian-cli
- obsidian-bases, json-canvas

### wshobson/agents (43 skills)
Comprehensive patterns (NOTE: Many have empty hashes)
- Backend: api-design-principles, architecture-patterns, microservices-patterns
- Frontend: react-state-management
- AI: prompt-engineering-patterns
- Cloud/K8s: helm, k8s-manifest-generator, istio, terraform
- CI/CD: deployment-pipeline-design, github-actions-templates, gitlab-ci-patterns
- Design: design-system-patterns, accessibility-compliance, interaction-design
- Mobile: mobile-ios-design, mobile-android-design, react-native-design

### Other sources (5 skills)
- jira-cli (code-and-sorts)
- find-skills (vercel-labs)
- browser-use (browser-use)
- mermaid-diagrams (softaworks)
- glab (henricook)

## Known Issues

**Skills with Empty Hashes** (~30 from wshobson/agents):
The sync script will attempt to reinstall these skills. If reinstallation fails, they may be from repositories that no longer exist or have moved. You can manually uninstall broken skills with:

```bash
claude plugin uninstall <skill-name>
```

## How It Works

### Initial Setup (New Machine)
1. Clone chezmoi repo
2. Run `chezmoi init` → prompts for machine config
3. Run `chezmoi apply`
4. Script detects missing skills
5. Skills installed via `claude plugin install`

### Updates (Existing Machine)
1. Edit `.chezmoidata/claude-skills.yml`
2. Commit and push to chezmoi repo
3. On other machines: `chezmoi update`
4. Script detects YAML hash change
5. New skills auto-installed

### Adding Work-Specific Skills
Edit the `work_specific_skills` section in `claude-skills.yml`:

```yaml
work_specific_skills:
  - gitlab-mr-review
  - code-review
  - simplify
```

## Verification Commands

After syncing, verify installation:

```bash
# Check total skill count
ls ~/.agents/skills | wc -l

# Check for empty hashes
jq '[.skills | to_entries[] | select(.value.skillFolderHash == "")] | length' ~/.agents/.skill-lock.json

# List broken skills
jq -r '.skills | to_entries[] | select(.value.skillFolderHash == "") | .key' ~/.agents/.skill-lock.json
```

## Maintenance

### Adding a New Skill
1. Edit `.chezmoidata/claude-skills.yml`
2. Add skill name to `base_skills` or `work_specific_skills`
3. Run `chezmoi apply` or `chezmoi update` on other machines

### Removing a Skill
1. Remove skill name from YAML
2. Manually uninstall: `claude plugin uninstall <skill-name>`

### Troubleshooting
- Check logs: `/tmp/claude-install-<skill-name>.log`
- Verify Claude CLI: `command -v claude`
- Verify jq installed: `command -v jq`

## Trade-offs

### Advantages
✅ Lightweight (~5KB YAML vs 17MB of skills)
✅ Declarative desired state
✅ Automated installation
✅ Context-aware (work/personal)
✅ Easy to audit and modify

### Limitations
❌ Requires internet on first run
❌ Depends on plugin repos being available
❌ No offline skill portability
❌ Installation takes time on new machines (~5 min for 107 skills)
