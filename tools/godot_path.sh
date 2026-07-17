#!/usr/bin/env bash
# Ruta al Godot 4.6.3 instalado por winget. Cambiar acá si se actualiza Godot,
# o exportar GODOT_EXE antes de correr los scripts para usar otro binario.
export GODOT_EXE="${GODOT_EXE:-${LOCALAPPDATA:-}/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.6.3-stable_win64_console.exe}"
if [ ! -f "$GODOT_EXE" ]; then
    echo "ERROR: no se encontró Godot en: $GODOT_EXE" >&2
    echo "Instalalo con winget o exportá GODOT_EXE con la ruta correcta." >&2
    return 1 2>/dev/null || exit 1
fi
