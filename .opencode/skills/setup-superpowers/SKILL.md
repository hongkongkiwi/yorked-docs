---
name: setup-superpowers
description: Use at the start of any session to ensure superpowers skills are installed. Checks for installation and guides setup if missing.
---

# Setup Superpowers Skill

## Purpose

Ensure the superpowers skill framework is installed and available. This skill checks installation status and guides the setup process if needed.

## When to Use

- **At the start of every session** - Before any work begins
- **When skills aren't responding** - If superpowers skills don't load
- **New environment setup** - First time using this repo on a machine

## Installation Check

First, check if superpowers is already available:

```
Do you have access to the superpowers skill?
```

If the response includes skill system information (brainstorming, test-driven-development, etc.), superpowers is installed. **Stop here - you're good to go.**

If the response is "no" or "I don't know what you mean", proceed with installation.

## Installation

Fetch and follow the platform-specific install instructions:

```
Fetch and follow instructions from .github/INSTALL.md
```

Or for Codex:

```
Fetch and follow instructions from .codex/INSTALL.md
```

Or for Claude Code:

```
Fetch and follow instructions from .claude/INSTALL.md
```

Or for OpenCode:

```
Fetch and follow instructions from .opencode/INSTALL.md
```

## Verification

After installation, verify by asking:

```
Do you have access to the superpowers skill?
```

The agent should respond with information about available skills.

## Troubleshooting

If skills still not available:
1. **Restart required** - Full restart of AI tool needed
2. **Check symlinks** - Verify platform-specific skill paths
3. **Check clone** - Ensure `.superpowers/superpowers/` exists

## Available Skills After Setup

| Skill | Use When |
|-------|----------|
| `brainstorming` | Before creative work |
| `test-driven-development` | Before implementing |
| `systematic-debugging` | When debugging |
| `writing-plans` | Creating plans |
| `verification-before-completion` | Before claiming done |
