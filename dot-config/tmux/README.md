# Tmux Configuration

## Setup

- **Config**: `tmux.conf` (requires tmux@3.5a)
- **Plugin Manager**: TPM is tracked in the repo and stowed to `~/.config/tmux/plugins/tpm`
- **Plugins**: Managed as git submodules
  - catppuccin/tmux - Theme
  - tmux-plugins/tmux-continuum - Auto session saving
  - sainnhe/tmux-fzf - FZF integration
  - tmux-plugins/tmux-resurrect - Session persistence
  - christoomey/vim-tmux-navigator - Vim/tmux navigation

## Commands

```bash
just bootstrap        # Install deps, sync submodules, stow configs
just sync-submodules  # Sync all tmux plugin submodules
just stow-configs     # Restow the tracked tmux config
```

## Key Bindings

- Reload config: `prefix + r`
- Status bar positioned at top
- Mouse support enabled
