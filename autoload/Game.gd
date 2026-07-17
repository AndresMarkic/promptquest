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
	if not PANTALLAS.has(pantalla):
		push_error("Game.goto: pantalla desconocida '%s'" % pantalla)
		return
	params = p_params
	# En modo test (-s) los autoloads también cargan pero no hay escena Main:
	# sin este guard el goto diferido crashea al cerrar el runner.
	var main := get_tree().root.get_node_or_null("Main")
	if main == null:
		return
	# Cargar ANTES de vaciar: si la escena falla en cargar, la pantalla
	# actual queda en pie en vez de dejar la app en negro.
	var escena: PackedScene = load(PANTALLAS[pantalla])
	for hijo in main.get_children():
		hijo.queue_free()
	main.add_child(escena.instantiate())
