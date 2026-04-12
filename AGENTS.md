# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## Overview

Personal dotfiles repository for macOS. Uses GNU Stow to symlink `dot-*` directories to `~/.*`.

**Never read files directly from `~/` or any absolute path under `/Users/`.** All dotfiles are managed here via Stow. Use the repo path instead:
- `~/.config/foo` → `dot-config/foo`
- `~/.claude/foo` → `dot-claude/foo`
- `~/foo` → `dot-foo` (if it exists)

If a file isn't in the repo, ask the user rather than reading it from the home directory.

## Key Commands

```bash
# Setup
just install-all         # Install all dependencies
just setup-all          # Setup configs, terminal, tmux
just stow-configs       # Create symlinks to home directory

# Development
just setup-tmux         # Setup tmux with plugins
just sync-submodules    # Update git submodules (tmux plugins)
just upgrade            # Upgrade Homebrew packages
```

## Architecture

- **Stow**: `dot-config/` → `~/.config/`, `dot-claude/` → `~/.claude/`
- **Justfile**: All installation and setup automation
- **Submodules**: tmux plugins in `dot-config/tmux/plugins/`
- **Shell**: zsh with Oh My Zsh, sources `.zshrc.*` files (gitignored)

## Tool Compatibility

`dot-config/opencode/` is OpenCode-specific config. Do not attempt to make it compatible with Claude Code or other AI tools.

## Subdirectory Documentation

When working with specific tools, read their documentation:
- Neovim: See `dot-config/nvim/README.md`
- Tmux: See `dot-config/tmux/README.md`
- Claude Code: See `dot-claude/README.md`

**Note**: Keep all README files concise (< 100 lines). Focus on essential architecture and commands only.
