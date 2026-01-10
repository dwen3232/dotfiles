# Tmux Configuration

## Setup

- **Config**: `tmux.conf` (requires tmux@3.5a)
- **Plugin Manager**: TPM installed at `~/.config/tmux/plugins/tpm`
- **Plugins**: Managed as git submodules
  - catppuccin/tmux - Theme
  - tmux-plugins/tmux-continuum - Auto session saving
  - sainnhe/tmux-fzf - FZF integration
  - tmux-plugins/tmux-resurrect - Session persistence
  - christoomey/vim-tmux-navigator - Vim/tmux navigation

## Commands

```bash
just setup-tmux          # Install TPM and plugins
just update-tmux-plugins # Update plugin submodules
just sync-submodules     # Sync all submodules
```

## Key Bindings

- Reload config: `prefix + r`
- Status bar positioned at top
- Mouse support enabled
