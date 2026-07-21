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
	var idioma: String = SaveData.get_value("language", "es")
	I18n.idioma_actual = idioma
	TranslationServer.set_locale(idioma)
	# Pantalla inicial: intro la primera vez, mapa después.
	goto.call_deferred("intro" if not SaveData.get_value("intro_seen", false) else "map")

func goto(pantalla: String, p_params: Dictionary = {}) -> void:
	if not PANTALLAS.has(pantalla):
		push_error("Game.goto: pantalla desconocida '%s'" % pantalla)
		return
	params = p_params
	# En modo test (-s) los autoloads cargan pero el nodo Game puede no estar aún
	# dentro del árbol (get_tree() == null) y tampoco hay escena Main. Sin estos
	# dos guardas el goto (diferido o disparado por un test) crashea. En el juego
	# real Game siempre está en el árbol, así que esto no cambia el comportamiento.
	# is_inside_tree() se chequea antes que get_tree() porque llamar get_tree()
	# fuera del árbol imprime un ERROR de motor (aunque devuelva null).
	if not is_inside_tree():
		return
	var main := get_tree().root.get_node_or_null("Main")
	if main == null:
		return
	# Cargar ANTES de vaciar: si la escena falla en cargar, la pantalla
	# actual queda en pie en vez de dejar la app en negro.
	var escena: PackedScene = load(PANTALLAS[pantalla])
	for hijo in main.get_children():
		hijo.queue_free()
	main.add_child(escena.instantiate())
