#!/usr/bin/env bash
# Abre el juego en ventana para probarlo a mano.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --path .
