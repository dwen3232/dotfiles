# Neovim Configuration

## Structure

- **Entry**: `init.lua` loads `dwen.core`, `dwen.prompts`, `dwen.lazy`
- **Plugin Manager**: Lazy.nvim (auto-installs on first run)
- **Plugins**: Organized in `lua/dwen/plugins/` by category:
  - `ai/` - AI/LLM integrations
  - `coding/` - Code editing and navigation
  - `editor/` - Editor features
  - `formatting/` - Code formatters
  - `linting/` - Linters
  - `lsp/` - Language Server Protocol configs
  - `testing/` - Testing frameworks
  - `ui/` - UI enhancements

## Core Configuration

Located in `lua/dwen/core/` - base settings, keymaps, and options.

## Adding Plugins

Add new plugin files in the appropriate `lua/dwen/plugins/` subdirectory. Lazy.nvim auto-imports from these directories.
