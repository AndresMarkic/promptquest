extends Control
## Certificación final: se muestra al vencer el Boss Final de la última unidad.
## Diploma "Ingeniero de IA" (spec curriculum §7). Game.params trae el resumen del boss.

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	Audio.festejo()
	_confeti()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	# el diploma es un panel dorado con borde brillante
	var panel := UiTheme.panel(Color("15152e"), 26)
	panel.custom_minimum_size = Vector2(600, 0)
	center.add_child(panel)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 16)
	panel.add_child(caja)

	var lbl_cert := UiTheme.etiqueta(I18n.t("CERT_TITULO"), 22, UiTheme.DORADO)
	lbl_cert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_cert.autowrap_mode = TextServer.AUTOWRAP_OFF
	caja.add_child(lbl_cert)

	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(160, 160)
	byte.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(byte)
	byte.set_animo("festejo")

	var rango := UiTheme.titulo(I18n.t("CERT_RANGO"), 40, UiTheme.DORADO)
	rango.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rango.autowrap_mode = TextServer.AUTOWRAP_OFF
	rango.size_flags_horizontal = Control.SIZE_FILL
	caja.add_child(rango)

	var texto := UiTheme.etiqueta(I18n.t("CERT_TEXTO"), 20, UiTheme.TEXTO)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.size_flags_horizontal = Control.SIZE_FILL
	caja.add_child(texto)

	var xp := UiTheme.etiqueta(I18n.t("CERT_XP") % Economy.xp_total(), 20, UiTheme.ACENTO)
	xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp.autowrap_mode = TextServer.AUTOWRAP_OFF
	caja.add_child(xp)

	var sub := UiTheme.etiqueta(I18n.t("CERT_SUB"), 16, UiTheme.TEXTO_SUAVE)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_OFF
	caja.add_child(sub)

	var btn := UiTheme.boton(I18n.t("CONTINUAR"))
	btn.pressed.connect(func(): Game.goto("map"))
	caja.add_child(btn)

func _confeti() -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(360, -20)
	p.amount = 90
	p.lifetime = 3.4
	p.preprocess = 1.4
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(380, 8)
	p.direction = Vector2(0, 1)
	p.spread = 25.0
	p.gravity = Vector2(0, 250)
	p.initial_velocity_min = 80.0
	p.initial_velocity_max = 240.0
	p.angular_velocity_min = -240.0
	p.angular_velocity_max = 240.0
	p.scale_amount_min = 4.0
	p.scale_amount_max = 9.0
	var g := Gradient.new()
	g.colors = PackedColorArray([UiTheme.DORADO, UiTheme.ACENTO, UiTheme.PRIMARIO, UiTheme.VIOLETA])
	g.offsets = PackedFloat32Array([0.0, 0.34, 0.67, 1.0])
	p.color_initial_ramp = g
	add_child(p)
