#!/usr/bin/env bash
# Corre todos los tests headless. Sale con código != 0 si algo falla.
set -euo pipefail
cd "$(dirname "$0")/.."
source tools/godot_path.sh
# Regenera el cache de clases globales (class_name). Sin este paso, el modo -s
# no resuelve TestCase/EconomyRules/etc. en un checkout limpio (.godot/ está
# gitignoreado) y el runner se cuelga sin llegar a quit().
if ! "$GODOT_EXE" --headless --path . --import > /dev/null; then
    echo "ERROR: falló el --import; no se corren los tests (caché inválida)." >&2
    exit 1
fi
"$GODOT_EXE" --headless --path . -s res://tests/test_runner.gd
