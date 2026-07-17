extends Node
## Autoload. Único acceso al guardado. El resto del juego NO toca disco.

var store: SaveStore

func _ready() -> void:
	store = SaveStore.new()

func get_value(clave: String, defecto = null):
	return store.data.get(clave, defecto)

func set_value(clave: String, valor) -> void:
	store.data[clave] = valor
	store.persist()
