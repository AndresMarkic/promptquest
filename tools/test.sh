#!/usr/bin/env bash
# Corre todos los tests headless. Sale con código != 0 si algo falla.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
# Regenera el cache de clases globales (class_name). Sin este paso, el modo -s
# no resuelve TestCase/EconomyRules/etc. en un checkout limpio (.godot/ está
# gitignoreado) y el runner se cuelga sin llegar a quit().
"$GODOT_EXE" --headless --path . --import > /dev/null
"$GODOT_EXE" --headless --path . -s res://tests/test_runner.gd
