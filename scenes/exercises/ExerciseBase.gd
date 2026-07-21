class_name ExerciseBase
extends Control
## Contrato de todo ejercicio (spec §5.3):
## setup(data) → el ejercicio se construye; emite answered(correct) UNA vez;
## muestra su feedback y luego emite continue_pressed.

signal answered(correct: bool)
signal continue_pressed

var data: Dictionary
var _respondido := false

func setup(d: Dictionary) -> void:
	data = d
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	push_error("ExerciseBase._build() debe sobreescribirse")

func _responder(correcto: bool) -> void:
	if _respondido:
		return
	_respondido = true
	answered.emit(correcto)
	_mostrar_feedback(correcto)

func _mostrar_feedback(correcto: bool) -> void:
	var panel := UiTheme.panel(Color("173d0c") if correcto else Color("4a1220"))
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -190
	add_child(panel)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	panel.add_child(caja)
	caja.add_child(UiTheme.etiqueta(I18n.t("CORRECTO") if correcto else I18n.t("INCORRECTO"),
		26, UiTheme.PRIMARIO if correcto else UiTheme.PELIGRO))
	caja.add_child(UiTheme.etiqueta(str(data.get("explanation", "")), 20, UiTheme.TEXTO_SUAVE))
	var btn := UiTheme.boton(I18n.t("CONTINUAR"), UiTheme.PRIMARIO if correcto else UiTheme.PELIGRO)
	btn.pressed.connect(func(): continue_pressed.emit())
	caja.add_child(btn)
