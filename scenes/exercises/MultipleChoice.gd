extends ExerciseBase
## data: {question: String, options: Array[String], correct: int, explanation: String}

var _botones: Array[Button] = []

func _build() -> void:
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_FULL_RECT)
	caja.offset_left = 26
	caja.offset_right = -26
	caja.offset_top = 116
	caja.offset_bottom = -40
	caja.add_theme_constant_override("separation", 15)
	caja.alignment = BoxContainer.ALIGNMENT_CENTER  # centra el grupo (llena el vacío)
	add_child(caja)

	var q := UiTheme.titulo(str(data["question"]), 27)
	q.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	q.size_flags_horizontal = Control.SIZE_FILL
	caja.add_child(q)
	var esp := Control.new()
	esp.custom_minimum_size = Vector2(0, 10)
	caja.add_child(esp)

	var letras := ["A", "B", "C", "D", "E"]
	var i := 0
	for opcion in data["options"]:
		var b := UiTheme.boton("%s    %s" % [letras[i], str(opcion)], UiTheme.PANEL)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, 74)
		b.add_theme_font_size_override("font_size", 22)
		var indice := i
		b.pressed.connect(func(): _elegir(indice))
		caja.add_child(b)
		_botones.append(b)
		i += 1

func _elegir(indice: int) -> void:
	var correcto: int = int(data["correct"])
	for k in _botones.size():
		_botones[k].disabled = true
	_botones[correcto].add_theme_stylebox_override("disabled",
		UiTheme._estilo(Color("2e6b12")))
	if indice != correcto:
		_botones[indice].add_theme_stylebox_override("disabled",
			UiTheme._estilo(Color("7a1f2b")))
	_responder(indice == correcto)
