#!/usr/bin/env bash
# Corre todos los tests headless. Sale con código != 0 si algo falla.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --headless --path . -s res://tests/test_runner.gd
