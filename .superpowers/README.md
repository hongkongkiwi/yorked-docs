# Superpowers Local Setup

This repository uses the [Superpowers](https://github.com/obra/superpowers) agentic skills framework for spec-driven development.

## Supported Platforms

- **Claude Code** - Via `~/.agents/skills` symlink
- **OpenCode** - Via `~/.config/opencode/skills` symlink + plugin
- **Codex** - Via `~/.agents/skills` symlink

## Quick Install (by Platform)

Tell your AI assistant to fetch and follow the install instructions:

### Codex
```
Fetch and follow instructions from .codex/INSTALL.md
```

### OpenCode
```
Fetch and follow instructions from .opencode/INSTALL.md
```

### Claude Code
```
Fetch and follow instructions from .claude/INSTALL.md
```

Or run the automated script:
```bash
./.superpowers/install.sh
```

## Manual Install

### Claude Code

```bash
# Clone superpowers locally
git clone https://github.com/obra/superpowers.git .superpowers/superpowers

# Create skills symlink
mkdir -p ~/.agents/skills
ln -s $(pwd)/.superpowers/superpowers/skills ~/.agents/skills/superpowers
```

### OpenCode

```bash
# Clone superpowers locally
git clone https://github.com/obra/superpowers.git .superpowers/superpowers

# Create skills symlink
mkdir -p ~/.config/opencode/skills
ln -s $(pwd)/.superpowers/superpowers/skills ~/.config/opencode/skills/superpowers

# Create plugin symlink
mkdir -p ~/.config/opencode/plugins
ln -s $(pwd)/.superpowers/superpowers/.opencode/plugins/superpowers.js ~/.config/opencode/plugins/superpowers.js
```

### Codex

```bash
# Clone superpowers locally
git clone https://github.com/obra/superpowers.git .superpowers/superpowers

# Create skills symlink
mkdir -p ~/.agents/skills
ln -s $(pwd)/.superpowers/superpowers/skills ~/.agents/skills/superpowers
```

## Verify Installation

After installation and restarting your AI tool, ask:

> "Do we have access to the superpowers skill?"

The agent should respond with information about the skill system.

## Available Skills

| Skill | When to Use |
|-------|-------------|
| `brainstorming` | Before any creative work or feature design |
| `test-driven-development` | Before implementing features or fixes |
| `systematic-debugging` | When investigating bugs |
| `writing-plans` | When creating implementation plans |
| `subagent-driven-development` | For parallel task execution |
| `verification-before-completion` | Before claiming work is done |
| `requesting-code-review` | Between tasks for quality checks |

## Project-Specific Skills

This repo has custom skills in `.skillshare/` (if any exist).

Skill priority: Project skills > Personal skills > Superpowers skills

## Updating

```bash
cd .superpowers/superpowers && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
# Remove symlinks
rm ~/.agents/skills/superpowers 2>/dev/null || true
rm ~/.config/opencode/skills/superpowers 2>/dev/null || true
rm ~/.config/opencode/plugins/superpowers.js 2>/dev/null || true

# Remove cloned repo
rm -rf .superpowers/superpowers
```

## Documentation

- [Superpowers README](https://github.com/obra/superpowers/blob/main/README.md)
- [docs/AGENTS.md](../docs/AGENTS.md) - This repo's agent workflow guide
