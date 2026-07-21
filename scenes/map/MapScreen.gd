extends Control
## Mapa: HUD superior + camino vertical de lecciones (spec §6).

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	_armar_hud_superior()
	_armar_camino()

func _armar_hud_superior() -> void:
	var fila := HBoxContainer.new()
	fila.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fila.offset_left = 20
	fila.offset_right = -20
	fila.offset_top = 14
	fila.offset_bottom = 54
	fila.add_theme_constant_override("separation", 18)
	add_child(fila)
	fila.add_child(Icono.nuevo("fuego", Economy.racha() > 0))
	fila.add_child(UiTheme.etiqueta(str(Economy.racha()), 24))
	fila.add_child(Icono.nuevo("corazon", Economy.hearts() > 0))
	fila.add_child(UiTheme.etiqueta(str(Economy.hearts()), 24))
	var espacio := Control.new()
	espacio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(espacio)
	fila.add_child(UiTheme.etiqueta("XP %d" % Economy.xp_total(), 24, UiTheme.DORADO))
	# Botón de ajustes: texto en vez de ⚙ (la fuente por defecto no trae emoji).
	var ajustes := Button.new()
	ajustes.text = I18n.t("AJUSTES")
	ajustes.flat = true
	ajustes.add_theme_font_size_override("font_size", 18)
	ajustes.add_theme_color_override("font_color", UiTheme.TEXTO_SUAVE)
	ajustes.pressed.connect(_abrir_ajustes)
	fila.add_child(ajustes)

func _abrir_ajustes() -> void:
	add_child(load("res://scenes/ui/SettingsPanel.tscn").instantiate())

func _armar_camino() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 70
	add_child(scroll)
	var caja := VBoxContainer.new()
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caja.add_theme_constant_override("separation", 34)
	scroll.add_child(caja)
	var avance: Dictionary = SaveData.get_value("lessons", {})
	var ids: Array = Content.UNIT1_IDS
	var i := 0
	for meta in Content.get_unit_lessons():
		# Cada nodo va en una fila con "aire" desigual a los costados → camino en zigzag.
		# (No usar position.x: los contenedores la pisan al ordenar a sus hijos.)
		var fila_nodo := HBoxContainer.new()
		fila_nodo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		caja.add_child(fila_nodo)
		var izq := Control.new()
		izq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		izq.size_flags_stretch_ratio = [1.0, 2.2, 0.5][i % 3]
		fila_nodo.add_child(izq)
		var nodo: LessonNode = load("res://scenes/map/LessonNode.tscn").instantiate()
		fila_nodo.add_child(nodo)
		var der := Control.new()
		der.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		der.size_flags_stretch_ratio = [1.0, 0.5, 2.2][i % 3]
		fila_nodo.add_child(der)
		var estado := ProgressLogic.estado(meta["id"], ids, avance)
		nodo.configurar(meta, estado, int(avance.get(meta["id"], {}).get("stars", 0)))
		nodo.pressed.connect(_al_tocar)
		i += 1

func _al_tocar(id: String) -> void:
	var avance: Dictionary = SaveData.get_value("lessons", {})
	var estado := ProgressLogic.estado(id, Content.UNIT1_IDS, avance)
	if estado == "completada":
		var d := ConfirmationDialog.new()
		d.dialog_text = I18n.t("REPASAR_PREGUNTA")
		d.ok_button_text = I18n.t("REPASAR")
		d.confirmed.connect(func(): Game.goto("lesson", {"lesson_id": id, "review": true}))
		add_child(d)
		d.popup_centered()
		return
	if not Economy.can_start_lesson():
		var d2 := AcceptDialog.new()
		d2.dialog_text = I18n.t("SIN_CORAZONES_MAPA")
		add_child(d2)
		d2.popup_centered()
		return
	Game.goto("lesson", {"lesson_id": id, "review": false})
