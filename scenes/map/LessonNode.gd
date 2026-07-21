extends VBoxContainer
class_name LessonNode
## Nodo del mapa: botón circular + título + estrellas.

signal pressed(id: String)

func configurar(meta: Dictionary, estado: String, estrellas: int) -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	var b := Button.new()
	b.custom_minimum_size = Vector2(110, 110)
	# "BOSS" como texto (el font por defecto no trae emoji: un 👑 saldría tofu).
	if meta.get("boss", false):
		b.text = "BOSS"
		b.add_theme_font_size_override("font_size", 22)
	# Tipo explícito: indexar un diccionario literal devuelve Variant y := no infiere.
	var color: Color = {"completada": UiTheme.DORADO, "actual": UiTheme.PRIMARIO,
		"bloqueada": Color("2a2a4e")}[estado]
	var st := StyleBoxFlat.new()
	st.bg_color = color
	st.set_corner_radius_all(55)
	for modo in ["normal", "hover", "pressed", "disabled"]:
		b.add_theme_stylebox_override(modo, st)
	b.disabled = estado == "bloqueada"
	if estado == "actual":
		# pulso para señalar la lección jugable
		b.pivot_offset = Vector2(55, 55)
		var t := create_tween().set_loops()
		t.tween_property(b, "scale", Vector2(1.08, 1.08), 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(b, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
	b.pressed.connect(func(): pressed.emit(meta["id"]))
	add_child(b)

	var titulo := UiTheme.etiqueta(str(meta["title"]), 18,
		UiTheme.TEXTO if estado != "bloqueada" else UiTheme.TEXTO_SUAVE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.custom_minimum_size = Vector2(220, 0)
	add_child(titulo)

	if estado == "completada":
		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		for k in 3:
			fila.add_child(Icono.nuevo("estrella", k < estrellas, 22.0))
		add_child(fila)
