extends ExerciseBase
## data: {question: String, options: Array[String], correct: int, explanation: String}

var _botones: Array[Button] = []

func _build() -> void:
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_FULL_RECT)
	caja.offset_left = 24
	caja.offset_right = -24
	caja.offset_top = 130
	caja.add_theme_constant_override("separation", 16)
	add_child(caja)
	caja.add_child(UiTheme.etiqueta(str(data["question"]), 28))
	var i := 0
	for opcion in data["options"]:
		var b := UiTheme.boton(str(opcion), UiTheme.PANEL)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
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
