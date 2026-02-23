#!/bin/bash
# Superpowers Local Installation Script
# Supports: Claude Code, OpenCode, Codex

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUPERPOWERS_DIR="$REPO_ROOT/.superpowers"

if ! command -v git &> /dev/null; then
    echo "Error: git is required for superpowers installation."
    exit 1
fi

echo "🦸 Installing Superpowers locally for Yoked..."
echo ""

# Check if superpowers is already cloned
if [ -d "$SUPERPOWERS_DIR/superpowers" ]; then
    echo "Superpowers already cloned. Updating..."
    cd "$SUPERPOWERS_DIR/superpowers"
    git pull --ff-only
else
    echo "Cloning superpowers repository..."
    mkdir -p "$SUPERPOWERS_DIR"
    git clone --depth 1 https://github.com/obra/superpowers.git "$SUPERPOWERS_DIR/superpowers"
fi

echo ""
echo "✅ Superpowers cloned to: $SUPERPOWERS_DIR/superpowers"
echo ""

# Claude Code setup
if command -v claude &> /dev/null || [ -d "$HOME/.claude" ]; then
    echo "🎯 Setting up for Claude Code..."
    mkdir -p "$HOME/.agents/skills"
    ln -sf "$SUPERPOWERS_DIR/superpowers/skills" "$HOME/.agents/skills/superpowers"
    echo "   ✓ Skills symlinked to ~/.agents/skills/superpowers"
    
    # Check if AGENTS.md exists and update if needed
    if [ -f "$REPO_ROOT/docs/AGENTS.md" ]; then
        echo "   ✓ docs/AGENTS.md exists (already configured)"
    fi
fi

# OpenCode setup
if command -v opencode &> /dev/null || [ -d "$HOME/.config/opencode" ]; then
    echo "🎯 Setting up for OpenCode..."
    mkdir -p "$HOME/.config/opencode/skills"
    ln -sf "$SUPERPOWERS_DIR/superpowers/skills" "$HOME/.config/opencode/skills/superpowers"
    echo "   ✓ Skills symlinked to ~/.config/opencode/skills/superpowers"
    
    # Plugin symlink
    mkdir -p "$HOME/.config/opencode/plugins"
    rm -f "$HOME/.config/opencode/plugins/superpowers.js"
    ln -s "$SUPERPOWERS_DIR/superpowers/.opencode/plugins/superpowers.js" "$HOME/.config/opencode/plugins/superpowers.js"
    echo "   ✓ Plugin symlinked to ~/.config/opencode/plugins/superpowers.js"
fi

# Codex setup
if command -v codex &> /dev/null || [ -d "$HOME/.codex" ]; then
    echo "🎯 Setting up for Codex..."
    mkdir -p "$HOME/.agents/skills"
    ln -sf "$SUPERPOWERS_DIR/superpowers/skills" "$HOME/.agents/skills/superpowers"
    echo "   ✓ Skills symlinked to ~/.agents/skills/superpowers"
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your AI coding tool (Claude Code, OpenCode, or Codex)"
echo "  2. Ask: 'do we have access to the superpowers skill'"
echo "  3. The agent should respond with skill system information"
echo ""
echo "Available skills:"
echo "  - brainstorming - Before any creative work"
echo "  - test-driven-development - RED-GREEN-REFACTOR"
echo "  - systematic-debugging - Root cause analysis"
echo "  - writing-plans - Implementation planning"
echo "  - subagent-driven-development - Parallel task execution"
echo "  - verification-before-completion - Verify before claiming done"
echo ""
echo "To update superpowers:"
echo "  cd $SUPERPOWERS_DIR/superpowers && git pull"
