#!/usr/bin/env bash
# Arranca el juego headless 1 frame y sale: detecta errores de parseo/autoloads.
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/godot_path.sh
# Import primero para que el smoke también funcione en un checkout limpio
# (sin .godot/ los recursos no cargan y daría un fallo espurio).
if ! "$GODOT_EXE" --headless --path . --import > /dev/null; then
    echo "ERROR: falló el --import; no se corre el smoke (caché inválida)." >&2
    exit 1
fi
"$GODOT_EXE" --headless --path . --quit
