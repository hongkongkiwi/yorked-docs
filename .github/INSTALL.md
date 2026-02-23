# Installing Superpowers for GitHub Copilot/Agent (Local Repo)

## Prerequisites

- GitHub Copilot or GitHub Agent
- Git installed
- This repository cloned locally

## Installation

1. **Clone the superpowers repository into this repo:**
   ```bash
   git clone https://github.com/obra/superpowers.git .superpowers/superpowers
   ```

2. **Create the skills symlink:**
   
   GitHub Agent uses the same skill discovery as Codex/Claude Code:
   ```bash
   mkdir -p ~/.agents/skills
   ln -s $(pwd)/.superpowers/superpowers/skills ~/.agents/skills/superpowers
   ```

   **Windows (PowerShell):**
   ```powershell
   New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
   $source = Join-Path (Get-Location) ".superpowers\superpowers\skills"
   $target = "$env:USERPROFILE\.agents\skills\superpowers"
   cmd /c mklink /J "$target" "$source"
   ```

3. **Restart GitHub Agent** to discover the skills.

## Verify

```bash
ls -la ~/.agents/skills/superpowers
```

You should see a symlink pointing to your local `.superpowers/superpowers/skills` directory.

## Updating

```bash
cd .superpowers/superpowers && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.agents/skills/superpowers
rm -rf .superpowers/superpowers
```
