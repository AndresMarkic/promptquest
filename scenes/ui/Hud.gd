extends Control
class_name Hud
## Barra superior de la lección: salir, progreso, corazones, combo.

signal exit_pressed

var _barra: ProgressBar
var _cont_corazones: HBoxContainer
var _lbl_combo: Label
var _lbl_tiempo: Label

func _ready() -> void:
	# La raíz es full-rect y en Fase 4 convive encima del ejercicio: con el
	# STOP default se tragaría todos los clicks. IGNORE deja pasar el mouse
	# y los hijos interactivos (botón salir) siguen recibiendo input.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 110)
	var fila := HBoxContainer.new()
	# Anchors + offsets coherentes: nada de position/size a mano sobre un
	# control anclado (warning en 4.6 y geometría dependiente del timing).
	fila.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fila.offset_left = 16
	fila.offset_top = 16
	fila.offset_right = -16
	fila.offset_bottom = 64
	fila.add_theme_constant_override("separation", 12)
	add_child(fila)

	var salir := Button.new()
	# TODO Fase 4: verificar glifo ✕ en la primera corrida con ventana.
	salir.text = "✕"
	salir.flat = true
	salir.add_theme_font_size_override("font_size", 30)
	salir.pressed.connect(func(): exit_pressed.emit())
	fila.add_child(salir)

	_barra = ProgressBar.new()
	_barra.min_value = 0
	_barra.show_percentage = false
	_barra.custom_minimum_size = Vector2(0, 22)
	_barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = UiTheme.PRIMARIO
	relleno.set_corner_radius_all(11)
	_barra.add_theme_stylebox_override("fill", relleno)
	fila.add_child(_barra)

	_cont_corazones = HBoxContainer.new()
	fila.add_child(_cont_corazones)

	_lbl_combo = UiTheme.etiqueta("", 20, UiTheme.DORADO)
	_lbl_combo.position = Vector2(16, 72)
	add_child(_lbl_combo)

	# Cuenta regresiva del boss, anclada arriba a la derecha (vacía fuera del boss).
	_lbl_tiempo = UiTheme.etiqueta("", 24, UiTheme.PELIGRO)
	_lbl_tiempo.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_lbl_tiempo.offset_left = -90
	_lbl_tiempo.offset_top = 72
	_lbl_tiempo.offset_right = -20
	add_child(_lbl_tiempo)

func set_tiempo(seg: int) -> void:
	_lbl_tiempo.text = ("%ds" % seg) if seg >= 0 else ""

func set_progreso(actual: int, total: int) -> void:
	_barra.max_value = total
	_barra.value = actual

func set_corazones(n: int) -> void:
	for h in _cont_corazones.get_children():
		# Fuera del árbol antes de liberar: queue_free solo no saca el nodo
		# hasta fin de frame y se vería un frame con 10 corazones.
		_cont_corazones.remove_child(h)
		h.queue_free()
	for k in EconomyRules.MAX_CORAZONES:
		_cont_corazones.add_child(Icono.nuevo("corazon", k < n))

func set_combo(n: int) -> void:
	if n >= 3:
		_lbl_combo.text = I18n.t("COMBO") % n
	else:
		_lbl_combo.text = ""
