#!/usr/bin/env bash
# Abre el juego en ventana para probarlo a mano.
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/godot_path.sh
# Import primero, igual que test.sh/smoke.sh: en un checkout limpio
# (.godot/ gitignoreado) las escenas no cargan y el juego arranca roto.
if ! "$GODOT_EXE" --headless --path . --import > /dev/null; then
    echo "ERROR: falló el --import; no se abre el juego (caché inválida)." >&2
    exit 1
fi
"$GODOT_EXE" --path .
