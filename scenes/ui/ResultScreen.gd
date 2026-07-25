extends Control
## Muestra el resumen que dejó Economy.on_lesson_finished en Game.params:
## {"xp": int, "estrellas": int, "racha": int, "sumo_racha": bool, "boss": bool}

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	Audio.festejo()
	var r: Dictionary = Game.params
	_confeti()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var caja := VBoxContainer.new()
	caja.custom_minimum_size = Vector2(600, 0)
	caja.add_theme_constant_override("separation", 22)
	center.add_child(caja)

	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(150, 150)
	byte.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(byte)
	byte.set_animo("festejo")

	var es_boss: bool = r.get("boss", false)
	var titulo := UiTheme.titulo(
		I18n.t("UNIDAD_COMPLETADA") if es_boss else I18n.t("LECCION_COMPLETADA"),
		38, UiTheme.PRIMARIO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.size_flags_horizontal = Control.SIZE_FILL
	caja.add_child(titulo)

	var outro := str(r.get("byte_outro", ""))
	if outro != "":
		var lbl_outro := UiTheme.etiqueta(outro, 20, UiTheme.TEXTO_SUAVE)
		lbl_outro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_outro.size_flags_horizontal = Control.SIZE_FILL
		caja.add_child(lbl_outro)

	var fila_estrellas := HBoxContainer.new()
	fila_estrellas.alignment = BoxContainer.ALIGNMENT_CENTER
	fila_estrellas.add_theme_constant_override("separation", 12)
	fila_estrellas.size_flags_horizontal = Control.SIZE_FILL
	for k in 3:
		var est := Icono.nuevo("estrella", k < int(r.get("estrellas", 1)), 78.0)
		fila_estrellas.add_child(est)
		_pop(est, 0.08 * k)
	caja.add_child(fila_estrellas)

	var lbl_xp := UiTheme.titulo("+0 XP", 34, UiTheme.DORADO)
	lbl_xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_xp.size_flags_horizontal = Control.SIZE_FILL
	caja.add_child(lbl_xp)
	var tween := create_tween()
	tween.tween_method(func(v: int): lbl_xp.text = "+%d XP" % v, 0, int(r.get("xp", 0)), 0.8)

	if r.get("sumo_racha", false):
		var fila_racha := HBoxContainer.new()
		fila_racha.alignment = BoxContainer.ALIGNMENT_CENTER
		fila_racha.add_theme_constant_override("separation", 8)
		fila_racha.size_flags_horizontal = Control.SIZE_FILL
		fila_racha.add_child(Icono.nuevo("fuego", true, 38.0))
		var lbl_racha := UiTheme.etiqueta(I18n.t("RACHA_DIAS") % int(r.get("racha", 1)), 26)
		lbl_racha.autowrap_mode = TextServer.AUTOWRAP_OFF
		lbl_racha.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fila_racha.add_child(lbl_racha)
		caja.add_child(fila_racha)

	var btn := UiTheme.boton(I18n.t("CONTINUAR"))
	btn.pressed.connect(func(): Game.goto("map"))
	caja.add_child(btn)

func _pop(nodo: Control, retraso: float) -> void:
	nodo.scale = Vector2(0.5, 0.5)
	nodo.pivot_offset = Vector2(39, 39)
	var t := create_tween()
	t.tween_interval(retraso)
	t.tween_property(nodo, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _confeti() -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(360, -20)
	p.amount = 70
	p.lifetime = 3.2
	p.preprocess = 1.2  # ya "lloviendo" cuando aparece la pantalla
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(380, 8)
	p.direction = Vector2(0, 1)
	p.spread = 25.0
	p.gravity = Vector2(0, 260)
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 240.0
	p.angular_velocity_min = -240.0
	p.angular_velocity_max = 240.0
	p.scale_amount_min = 4.0
	p.scale_amount_max = 8.0
	var g := Gradient.new()
	g.colors = PackedColorArray([UiTheme.ACENTO, UiTheme.PRIMARIO, UiTheme.DORADO, UiTheme.VIOLETA])
	g.offsets = PackedFloat32Array([0.0, 0.34, 0.67, 1.0])
	p.color_initial_ramp = g
	add_child(p)
