#!/bin/bash

VENV_PATH="$HOME/.virtualenvs/neovim"

if [ ! -d "$VENV_PATH" ]; then
    echo "Creating venv..."
    python3 -m venv "$VENV_PATH"
    echo "Activating..."
    source "$VENV_PATH/bin/activate"
    echo "Installing deps..."
    pip install pynvim jupyter_client cairosvg plotly kaleido pnglatex pyperclip
else
    echo "Virtual environment already exists. Activating..."
    source "$VENV_PATH/bin/activate"
fi

echo "Neovim virtual environment is ready!"

