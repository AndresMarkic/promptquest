extends Control
## Raíz del juego: contiene la pantalla activa. Game (autoload) la reemplaza.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# Bloom global: hace que los colores neón brillen de verdad.
	add_child(UiTheme.crear_entorno_glow())
