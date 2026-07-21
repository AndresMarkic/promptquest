extends ExerciseBase
## data: {goal: String, solution: Array[String], distractors: Array[String], explanation: String}
## Tap-to-place: tocar un bloque del pool lo mueve a tu respuesta y viceversa.

var _respuesta: Array = []
var _fila_respuesta: HFlowContainer
var _pool_cont: HFlowContainer
var _btn_verificar: Button

func _build() -> void:
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_FULL_RECT)
	caja.offset_left = 24
	caja.offset_right = -24
	caja.offset_top = 130
	caja.add_theme_constant_override("separation", 20)
	add_child(caja)
	caja.add_child(UiTheme.etiqueta(str(data["goal"]), 28))

	var zona := UiTheme.panel(Color("0d0d22"))
	zona.custom_minimum_size = Vector2(0, 140)
	caja.add_child(zona)
	_fila_respuesta = HFlowContainer.new()
	_fila_respuesta.add_theme_constant_override("h_separation", 10)
	zona.add_child(_fila_respuesta)

	_pool_cont = HFlowContainer.new()
	_pool_cont.add_theme_constant_override("h_separation", 10)
	caja.add_child(_pool_cont)

	var pool := BlockLogic.armar_pool(data["solution"], data.get("distractors", []),
		hash(str(data["goal"])))  # semilla estable por ejercicio
	for bloque in pool:
		_pool_cont.add_child(_hacer_bloque(str(bloque), true))

	_btn_verificar = UiTheme.boton(I18n.t("VERIFICAR"), UiTheme.ACENTO)
	_btn_verificar.disabled = true
	_btn_verificar.pressed.connect(_verificar)
	caja.add_child(_btn_verificar)

func _hacer_bloque(texto: String, en_pool: bool) -> Button:
	var b := UiTheme.boton(texto, UiTheme.PANEL if en_pool else UiTheme.ACENTO)
	b.add_theme_font_size_override("font_size", 22)
	b.custom_minimum_size = Vector2(0, 52)
	b.pressed.connect(func(): _mover(b, en_pool))
	return b

func _mover(b: Button, estaba_en_pool: bool) -> void:
	if _respondido:
		return
	var texto := b.text
	b.queue_free()
	if estaba_en_pool:
		_respuesta.append(texto)
		_fila_respuesta.add_child(_hacer_bloque(texto, false))
	else:
		_respuesta.erase(texto)  # borra la primera aparición (ok con textos repetidos)
		_pool_cont.add_child(_hacer_bloque(texto, true))
	_btn_verificar.disabled = _respuesta.is_empty()

func _verificar() -> void:
	_btn_verificar.disabled = true
	_responder(BlockLogic.es_correcta(_respuesta, data["solution"]))
