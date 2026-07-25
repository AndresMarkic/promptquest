extends VBoxContainer
class_name LessonNode
## Nodo del mapa: botón circular con número/estado + título + estrellas.

signal pressed(id: String)

var _boton: Button

func configurar(meta: Dictionary, estado: String, estrellas: int, numero: int) -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 6)
	var es_boss: bool = meta.get("boss", false)

	var b := Button.new()
	b.custom_minimum_size = Vector2(104, 104)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER  # circular, no se estira al ancho
	if es_boss:
		b.text = "BOSS"
		b.add_theme_font_size_override("font_size", 22)
	elif estado == "completada":
		b.text = "✓"
		b.add_theme_font_size_override("font_size", 44)
	else:
		b.text = str(numero)
		b.add_theme_font_size_override("font_size", 40)

	var color: Color = {"completada": UiTheme.DORADO, "actual": UiTheme.PRIMARIO,
		"bloqueada": Color("20203f")}[estado]
	var st := StyleBoxFlat.new()
	st.bg_color = color
	st.set_corner_radius_all(52)
	st.border_width_top = 3
	st.border_color = color.lightened(0.4) if estado != "bloqueada" else Color("34345e")
	if estado != "bloqueada":
		st.shadow_color = Color(color.r, color.g, color.b, 0.55)
		st.shadow_size = 22
		st.shadow_offset = Vector2(0, 6)
	st.anti_aliasing = true
	for modo in ["normal", "hover", "pressed", "disabled", "focus"]:
		b.add_theme_stylebox_override(modo, st)
	var oscuro := color.get_luminance() > 0.5
	b.add_theme_color_override("font_color", Color("2a2205") if oscuro else UiTheme.TEXTO)
	b.add_theme_color_override("font_disabled_color", Color("50507e"))
	b.disabled = estado == "bloqueada"
	if estado == "actual":
		b.pivot_offset = Vector2(52, 52)
		var t := create_tween().set_loops()
		t.tween_property(b, "scale", Vector2(1.09, 1.09), 0.6).set_trans(Tween.TRANS_SINE)
		t.tween_property(b, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE)
	b.pressed.connect(func(): pressed.emit(meta["id"]))
	add_child(b)
	_boton = b

	var titulo := UiTheme.etiqueta(str(meta["title"]), 17,
		UiTheme.TEXTO if estado != "bloqueada" else UiTheme.TEXTO_SUAVE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.custom_minimum_size = Vector2(200, 0)
	add_child(titulo)

	var fila := HBoxContainer.new()
	fila.alignment = BoxContainer.ALIGNMENT_CENTER
	fila.add_theme_constant_override("separation", 2)
	for k in 3:
		fila.add_child(Icono.nuevo("estrella", estado == "completada" and k < estrellas, 20.0))
	add_child(fila)

## Centro del botón en el espacio del padre (lienzo), para dibujar el camino.
func centro_boton() -> Vector2:
	if _boton == null:
		return position
	return position + _boton.position + _boton.size / 2.0
