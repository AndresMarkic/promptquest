extends Node
## Autoload. Navegación entre pantallas (spec §6). Única forma de cambiar pantalla.

const PANTALLAS := {
	"intro": "res://scenes/intro/IntroScreen.tscn",
	"map": "res://scenes/map/MapScreen.tscn",
	"lesson": "res://scenes/lesson/LessonScreen.tscn",
	"result": "res://scenes/ui/ResultScreen.tscn",
}

var params: Dictionary = {}  # parámetros para la pantalla entrante

func _ready() -> void:
	TranslationServer.set_locale(SaveData.get_value("language", "es"))
	# Pantalla inicial: intro la primera vez, mapa después.
	goto.call_deferred("intro" if not SaveData.get_value("intro_seen", false) else "map")

func goto(pantalla: String, p_params: Dictionary = {}) -> void:
	params = p_params
	# En modo test (-s) los autoloads también cargan pero no hay escena Main:
	# sin este guard el goto diferido crashea al cerrar el runner.
	var main := get_tree().root.get_node_or_null("Main")
	if main == null:
		return
	for hijo in main.get_children():
		hijo.queue_free()
	var escena: PackedScene = load(PANTALLAS[pantalla])
	main.add_child(escena.instantiate())
