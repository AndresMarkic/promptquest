extends Node
## Autoload. Único acceso al guardado. El resto del juego NO toca disco.

var store: SaveStore

func _init() -> void:
	# En _init (no _ready): el store queda listo apenas se instancia el
	# autoload, sin depender del orden de _ready ni del árbol de escena.
	store = SaveStore.new(_ruta_guardado())

func get_value(clave: String, defecto = null):
	return store.data.get(clave, defecto)

func set_value(clave: String, valor) -> void:
	store.data[clave] = valor
	store.persist()

static func _ruta_guardado() -> String:
	# En Godot 4.6.3 el modo -s SÍ carga autoloads: sin este desvío, cada
	# corrida de tests pisaría user://save.json (el save real del jugador).
	for arg in OS.get_cmdline_args():
		if arg.ends_with("test_runner.gd"):
			return "user://save_test.json"
	return "user://save.json"
