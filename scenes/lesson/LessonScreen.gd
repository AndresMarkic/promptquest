extends Control
## Corre una lección completa: HUD + ejercicios en cadena (spec §6).
## Espera Game.params = {"lesson_id": String, "review": bool}

const ESCENAS_EJERCICIO := {
	"multiple_choice": "res://scenes/exercises/MultipleChoice.tscn",
	"block_builder": "res://scenes/exercises/BlockBuilder.tscn",
}

var leccion: Dictionary
var ejercicios: Array = []
var indice := 0
var errores := 0
var perfectas := 0
var combo := 0
var es_repaso := false
var _hud: Hud
var _actual: ExerciseBase = null
var _inicio_ms := 0

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	leccion = Content.get_lesson(Game.params["lesson_id"])
	ejercicios = leccion.get("exercises", [])
	es_repaso = Game.params.get("review", false)
	_hud = load("res://scenes/ui/Hud.tscn").instantiate()
	_hud.exit_pressed.connect(_confirmar_salida)
	add_child(_hud)
	if not _hud.is_node_ready():
		# Bajo el runner (-s) el árbol todavía no está "ready" y add_child no
		# dispara _ready() del Hud: se notifica a mano (mismo patrón que
		# test_ui_hud). En el juego real add_child ya lo dejó ready y no hace nada.
		_hud.notification(Node.NOTIFICATION_READY)
	_hud.set_corazones(Economy.hearts())
	Economy.hearts_changed.connect(func(n): _hud.set_corazones(n))
	_inicio_ms = Time.get_ticks_msec()
	_mostrar_ejercicio()

func _mostrar_ejercicio() -> void:
	if _actual != null:
		_actual.queue_free()
		_actual = null
	if indice >= ejercicios.size():
		_terminar()
		return
	_hud.set_progreso(indice, ejercicios.size())
	var ej: Dictionary = ejercicios[indice]
	if not ESCENAS_EJERCICIO.has(ej["type"]) or not ResourceLoader.exists(ESCENAS_EJERCICIO[ej["type"]]):
		push_warning("Tipo de ejercicio sin escena todavía: " + str(ej["type"]))
		_siguiente()
		return
	var esc: ExerciseBase = load(ESCENAS_EJERCICIO[ej["type"]]).instantiate()
	add_child(esc)
	move_child(esc, 1)  # debajo del HUD
	esc.setup(ej)
	esc.answered.connect(_al_responder)
	esc.continue_pressed.connect(_siguiente)
	_actual = esc

func _al_responder(correcto: bool) -> void:
	if correcto:
		perfectas += 1
		combo += 1
	else:
		errores += 1
		combo = 0
		Economy.perder_corazon()
		if Economy.hearts() <= 0:
			_sin_corazones()
			return
	_hud.set_combo(combo)

func _siguiente() -> void:
	indice += 1
	_mostrar_ejercicio()

func _terminar() -> void:
	var segundos := (Time.get_ticks_msec() - _inicio_ms) / 1000.0
	var resumen := Economy.on_lesson_finished(
		leccion["id"], perfectas, errores, segundos, es_repaso, bool(leccion.get("boss", false)))
	Game.goto("result", resumen)

func _confirmar_salida() -> void:
	var d := ConfirmationDialog.new()
	d.dialog_text = "Si salís ahora perdés el progreso de esta lección. ¿Salir?"
	d.ok_button_text = "Salir"
	d.cancel_button_text = "Seguir"
	d.confirmed.connect(func(): Game.goto("map"))
	add_child(d)
	d.popup_centered()

func _sin_corazones() -> void:
	var d := AcceptDialog.new()
	d.dialog_text = "¡Te quedaste sin corazones! Repasá una lección completada para recuperar uno."
	d.confirmed.connect(func(): Game.goto("map"))
	d.canceled.connect(func(): Game.goto("map"))
	add_child(d)
	d.popup_centered()
