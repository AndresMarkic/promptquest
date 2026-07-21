extends Control
## Muestra el resumen que dejó Economy.on_lesson_finished en Game.params:
## {"xp": int, "estrellas": int, "racha": int, "sumo_racha": bool}

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	Audio.festejo()
	var r: Dictionary = Game.params
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.custom_minimum_size = Vector2(560, 0)
	caja.add_theme_constant_override("separation", 24)
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(caja)

	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(140, 140)
	byte.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(byte)
	byte.set_animo("festejo")  # después de add_child: set_animo usa create_tween

	var es_boss: bool = r.get("boss", false)
	var titulo := UiTheme.etiqueta(
		I18n.t("UNIDAD_COMPLETADA") if es_boss else I18n.t("LECCION_COMPLETADA"),
		36, UiTheme.PRIMARIO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	var outro := str(r.get("byte_outro", ""))
	if outro != "":
		var lbl_outro := UiTheme.etiqueta(outro, 20, UiTheme.TEXTO_SUAVE)
		lbl_outro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caja.add_child(lbl_outro)

	var fila_estrellas := HBoxContainer.new()
	fila_estrellas.alignment = BoxContainer.ALIGNMENT_CENTER
	for k in 3:
		fila_estrellas.add_child(Icono.nuevo("estrella", k < int(r.get("estrellas", 1)), 72.0))
	caja.add_child(fila_estrellas)

	var lbl_xp := UiTheme.etiqueta("+0 XP", 32, UiTheme.DORADO)
	lbl_xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(lbl_xp)
	var tween := create_tween()
	tween.tween_method(func(v: int): lbl_xp.text = "+%d XP" % v, 0, int(r.get("xp", 0)), 0.8)

	if r.get("sumo_racha", false):
		var fila_racha := HBoxContainer.new()
		fila_racha.alignment = BoxContainer.ALIGNMENT_CENTER
		fila_racha.add_child(Icono.nuevo("fuego", true, 36.0))
		fila_racha.add_child(UiTheme.etiqueta(I18n.t("RACHA_DIAS") % int(r.get("racha", 1)), 26))
		caja.add_child(fila_racha)

	var btn := UiTheme.boton(I18n.t("CONTINUAR"))
	btn.pressed.connect(func(): Game.goto("map"))
	caja.add_child(btn)
