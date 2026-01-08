---
name: setup-hooks
description: Set up project-level Claude hooks
userInvocable: true
argument-hint: [additional-context]
---

# Setup Hooks

Creates the `.claude/hooks/post-edit.sh` script in the current project that automatically formats files after editing.

## Instructions

The user may provide additional context via `$ARGUMENTS`. Use this to customize the hook script behavior beyond the default formatting (e.g., run tests, custom linting rules, etc.).

1. Analyze the current project to detect languages and frameworks:
   - Check for package.json (Node/JS/TS project)
   - Check for requirements.txt, setup.py, pyproject.toml (Python project)
   - Check for Cargo.toml (Rust project)
   - Check for go.mod (Go project)
   - Check for Gemfile (Ruby project)
   - Look at actual source files in common directories (src/, lib/, etc.)

2. For each detected language/framework, check if appropriate formatters are installed:
   - **JS/TS**: prettier, eslint with --fix
   - **Python**: black, ruff, autopep8
   - **Rust**: rustfmt
   - **Go**: gofmt, goimports
   - **Ruby**: rubocop

3. Create the `.claude/hooks` directory in the current working directory

4. Generate a custom `post-edit.sh` script that ONLY handles the file types found in this project:
   - Include only relevant case statements for detected languages
   - Use the formatters that are actually installed
   - If `$ARGUMENTS` is provided, incorporate those instructions into the script
   - Add comments explaining what the script does for this specific project
   - Keep it minimal and focused

5. Make the script executable with `chmod +x .claude/hooks/post-edit.sh`

6. Inform the user:
   - What languages were detected
   - Which formatters are being used
   - Suggest installing any missing formatters for detected languages (if applicable)
   - Confirm the hook is ready
