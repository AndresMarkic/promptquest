extends Control
class_name SettingsPanel
## Overlay de ajustes (spec §6): idioma en vivo y sonido on/off.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var velo := ColorRect.new()
	velo.color = Color(0.02, 0.02, 0.07, 0.72)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(velo)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := UiTheme.panel()
	panel.custom_minimum_size = Vector2(500, 0)
	center.add_child(panel)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 22)
	panel.add_child(caja)
	var tit := UiTheme.titulo(I18n.t("AJUSTES"), 30, UiTheme.ACENTO)
	tit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(tit)

	var fila_idioma := HBoxContainer.new()
	fila_idioma.add_theme_constant_override("separation", 16)
	var li := UiTheme.etiqueta(I18n.t("IDIOMA"), 24)
	li.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_idioma.add_child(li)
	var sel := OptionButton.new()
	sel.add_item("Español")   # índice 0 → "es"
	sel.add_item("English")   # índice 1 → "en"
	sel.selected = 0 if Content.idioma() == "es" else 1
	sel.item_selected.connect(func(i: int):
		Content.set_idioma("es" if i == 0 else "en")
		Game.goto("map"))  # reconstruye el mapa en el idioma nuevo
	fila_idioma.add_child(sel)
	caja.add_child(fila_idioma)

	var fila_sonido := HBoxContainer.new()
	fila_sonido.add_theme_constant_override("separation", 16)
	var ls := UiTheme.etiqueta(I18n.t("SONIDO"), 24)
	ls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila_sonido.add_child(ls)
	var chk := CheckButton.new()
	var ajustes: Dictionary = SaveData.get_value("settings", {"sound": true})
	chk.button_pressed = ajustes.get("sound", true)
	chk.toggled.connect(func(on: bool):
		ajustes["sound"] = on
		SaveData.set_value("settings", ajustes))
	fila_sonido.add_child(chk)
	caja.add_child(fila_sonido)

	var cerrar := UiTheme.boton(I18n.t("CERRAR"), UiTheme.PANEL)
	cerrar.pressed.connect(queue_free)
	caja.add_child(cerrar)
