#!/usr/bin/env bash
# Genera assets/icon.png con la cara de Byte (sin assets externos).
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --headless --path . -s res://tools/gen_icon.gd
