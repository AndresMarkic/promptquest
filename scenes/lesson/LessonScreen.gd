extends Control
## Corre una lección completa: HUD + ejercicios en cadena (spec §6).
## Espera Game.params = {"lesson_id": String, "review": bool}

const ESCENAS_EJERCICIO := {
	"multiple_choice": "res://scenes/exercises/MultipleChoice.tscn",
	"block_builder": "res://scenes/exercises/BlockBuilder.tscn",
}
const BOSS_SEGUNDOS := 20  # cuenta regresiva por ejercicio en el boss (spec §2.4)

var leccion: Dictionary
var ejercicios: Array = []
var indice := 0
var errores := 0
var perfectas := 0
var combo := 0
var es_repaso := false
var es_boss := false
var _hud: Hud
var _actual: ExerciseBase = null
var _byte: Mascot
var _overlay_intro: Control = null
var _timer: Timer = null
var _inicio_ms := 0

func _ready() -> void:
	# el fondo toma el color de ambiente de la zona de esta lección
	UiTheme.fondo_pantalla(self, Content.color_de_leccion(Game.params["lesson_id"]))
	leccion = Content.get_lesson(Game.params["lesson_id"])
	ejercicios = leccion.get("exercises", [])
	es_repaso = Game.params.get("review", false)
	es_boss = bool(leccion.get("boss", false))
	if es_boss:
		_timer = Timer.new()
		_timer.one_shot = true
		_timer.timeout.connect(_tiempo_agotado)
		add_child(_timer)
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
	# Byte en la esquina inferior izquierda, reaccionando a cada respuesta.
	_byte = load("res://scenes/mascot/Mascot.tscn").instantiate()
	_byte.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_KEEP_SIZE)
	_byte.offset_left = 18
	_byte.offset_top = -142
	_byte.offset_right = 146
	_byte.offset_bottom = -14
	add_child(_byte)
	_inicio_ms = Time.get_ticks_msec()
	# Byte saluda con byte_intro antes del primer ejercicio (si la lección lo trae).
	var intro := str(leccion.get("byte_intro", ""))
	if intro != "":
		_mostrar_intro_byte(intro)
	else:
		_mostrar_ejercicio()

func _mostrar_intro_byte(texto: String) -> void:
	_overlay_intro = Control.new()
	_overlay_intro.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay_intro)
	var velo := ColorRect.new()
	velo.color = Color(0.07, 0.07, 0.17, 0.92)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay_intro.add_child(velo)
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.custom_minimum_size = Vector2(560, 0)
	caja.add_theme_constant_override("separation", 24)
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	_overlay_intro.add_child(caja)
	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(140, 140)
	byte.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(byte)
	var lbl := UiTheme.etiqueta(texto, 24)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(lbl)
	var btn := UiTheme.boton(I18n.t("CONTINUAR"))
	btn.pressed.connect(_cerrar_intro)
	caja.add_child(btn)

func _cerrar_intro() -> void:
	if _overlay_intro != null:
		_overlay_intro.queue_free()
		_overlay_intro = null
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
	# is_inside_tree(): en el juego real el timer siempre está en el árbol; bajo el
	# runner headless no, y start() imprimiría un ERROR (los tests simulan el timeout).
	if es_boss and _timer.is_inside_tree():
		_timer.start(BOSS_SEGUNDOS)

func _process(_delta: float) -> void:
	if es_boss and _timer != null and not _timer.is_stopped():
		_hud.set_tiempo(int(ceil(_timer.time_left)))

func _tiempo_agotado() -> void:
	# Se acabó el tiempo del ejercicio: cuenta como error y se pasa al siguiente.
	if _actual != null:
		_actual.bloquear()
	Audio.error()
	errores += 1
	combo = 0
	_hud.set_combo(0)
	_hud.set_tiempo(-1)
	Economy.perder_corazon()
	if Economy.hearts() <= 0:
		_sin_corazones()
		return
	_siguiente()

func _al_responder(correcto: bool) -> void:
	if es_boss and _timer != null:
		_timer.stop()
	if _byte != null:
		_byte.set_animo("feliz" if correcto else "triste")
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
	# Boss: se aprueba con ≥9 de 12 correctas, es decir ≤3 errores (spec §2.4).
	if es_boss and errores > 3:
		var d := AcceptDialog.new()
		d.dialog_text = I18n.t("BOSS_FALLADO")
		d.confirmed.connect(func(): Game.goto("map"))
		d.canceled.connect(func(): Game.goto("map"))
		add_child(d)
		d.popup_centered()
		return
	var resumen := Economy.on_lesson_finished(
		leccion["id"], perfectas, errores, segundos, es_repaso, es_boss)
	resumen["byte_outro"] = leccion.get("byte_outro", "")
	resumen["boss"] = es_boss
	# El boss de la última zona lleva a la certificación en vez del resultado normal.
	if es_boss and Content.es_leccion_final(leccion["id"]):
		Game.goto("cert", resumen)
	else:
		Game.goto("result", resumen)

func _confirmar_salida() -> void:
	var d := ConfirmationDialog.new()
	d.dialog_text = I18n.t("SALIR_CONFIRMA")
	d.ok_button_text = I18n.t("SALIR")
	d.cancel_button_text = I18n.t("SEGUIR")
	d.confirmed.connect(func(): Game.goto("map"))
	add_child(d)
	d.popup_centered()

func _sin_corazones() -> void:
	var d := AcceptDialog.new()
	d.dialog_text = I18n.t("SIN_CORAZONES")
	d.confirmed.connect(func(): Game.goto("map"))
	d.canceled.connect(func(): Game.goto("map"))
	add_child(d)
	d.popup_centered()
