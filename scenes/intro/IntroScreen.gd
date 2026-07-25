extends Control
## 3 pantallas de historia, solo la primera vez (spec §3). Saltable.

var pagina := 0
var _lbl: Label
var _btn: Button

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var caja := VBoxContainer.new()
	caja.custom_minimum_size = Vector2(580, 0)
	caja.add_theme_constant_override("separation", 28)
	center.add_child(caja)
	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(220, 300)  # canvas alto para el cuerpo entero
	byte.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	byte.mostrar_cuerpo = true
	caja.add_child(byte)
	_lbl = UiTheme.etiqueta(I18n.t("INTRO_1"), 26)
	_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl.size_flags_horizontal = Control.SIZE_FILL
	caja.add_child(_lbl)
	_btn = UiTheme.boton(I18n.t("CONTINUAR"))
	_btn.pressed.connect(_avanzar)
	caja.add_child(_btn)
	var saltar := UiTheme.boton(I18n.t("SALTAR"), UiTheme.PANEL)
	saltar.pressed.connect(_terminar)
	caja.add_child(saltar)

func _avanzar() -> void:
	pagina += 1
	if pagina >= 3:
		_terminar()
		return
	_lbl.text = I18n.t("INTRO_%d" % (pagina + 1))
	if pagina == 2:
		_btn.text = I18n.t("EMPEZAR")

func _terminar() -> void:
	SaveData.set_value("intro_seen", true)
	Game.goto("map")
