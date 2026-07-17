extends Control
class_name Hud
## Barra superior de la lección: salir, progreso, corazones, combo.

signal exit_pressed

var _barra: ProgressBar
var _cont_corazones: HBoxContainer
var _lbl_combo: Label

func _ready() -> void:
	custom_minimum_size = Vector2(0, 110)
	var fila := HBoxContainer.new()
	fila.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fila.add_theme_constant_override("separation", 12)
	fila.position = Vector2(16, 16)
	fila.size = Vector2(688, 48)
	add_child(fila)

	var salir := Button.new()
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

func set_progreso(actual: int, total: int) -> void:
	_barra.max_value = total
	_barra.value = actual

func set_corazones(n: int) -> void:
	for h in _cont_corazones.get_children():
		h.queue_free()
	for k in EconomyRules.MAX_CORAZONES:
		_cont_corazones.add_child(Icono.nuevo("corazon", k < n))

func set_combo(n: int) -> void:
	if n >= 3:
		# Texto literal en español: el i18n propio llega en la Tarea 7.3.
		_lbl_combo.text = "¡Combo x%d!" % n
	else:
		_lbl_combo.text = ""
