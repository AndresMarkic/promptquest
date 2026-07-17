#!/usr/bin/env bash
# Arranca el juego headless 1 frame y sale: detecta errores de parseo/autoloads.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --headless --path . --quit
