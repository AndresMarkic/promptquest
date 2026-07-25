extends Control
## Mapa: HUD superior en píldora + header + camino serpenteante de lecciones.

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	_armar_hud_superior()
	_armar_camino()

func _stat(tipo: String, valor: String, activo: bool, color: Color) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 5)
	h.add_child(Icono.nuevo(tipo, activo, 26.0))
	var l := UiTheme.etiqueta(valor, 22, color)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF  # clave: sin esto "85" se parte vertical
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	h.add_child(l)
	return h

func _armar_hud_superior() -> void:
	var barra := HBoxContainer.new()
	barra.set_anchors_preset(Control.PRESET_TOP_WIDE)
	barra.offset_left = 16
	barra.offset_right = -16
	barra.offset_top = 14
	barra.offset_bottom = 66
	add_child(barra)

	var pill := UiTheme.panel(UiTheme.PANEL, 26)
	pill.add_theme_constant_override("separation", 0)
	barra.add_child(pill)
	var fila := HBoxContainer.new()
	fila.add_theme_constant_override("separation", 18)
	pill.add_child(fila)
	fila.add_child(_stat("fuego", str(Economy.racha()), Economy.racha() > 0, UiTheme.DORADO))
	fila.add_child(_stat("corazon", str(Economy.hearts()), Economy.hearts() > 0, UiTheme.TEXTO))
	fila.add_child(_stat("diamante", str(Economy.xp_total()), true, UiTheme.ACENTO))

	var esp := Control.new()
	esp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.add_child(esp)

	# botón de ajustes (engranaje dibujado)
	var gear := Button.new()
	gear.flat = true
	gear.custom_minimum_size = Vector2(52, 52)
	var eng := Icono.nuevo("engranaje", true, 32.0)
	eng.set_anchors_preset(Control.PRESET_FULL_RECT)
	gear.add_child(eng)
	gear.pressed.connect(_abrir_ajustes)
	barra.add_child(gear)

func _abrir_ajustes() -> void:
	add_child(load("res://scenes/ui/SettingsPanel.tscn").instantiate())

func _header_zona(u: Dictionary) -> Control:
	var cont := Control.new()
	cont.custom_minimum_size = Vector2(720, 82)
	var color := Color(str(u.get("color", "22c9ff")))
	var t := UiTheme.titulo(str(u["zona"]), 28, color)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_OFF
	t.set_anchors_preset(Control.PRESET_TOP_WIDE)
	t.position = Vector2(0, 14)
	cont.add_child(t)
	var s := UiTheme.etiqueta(str(u["sub"]), 17, UiTheme.TEXTO_SUAVE)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.autowrap_mode = TextServer.AUTOWRAP_OFF
	s.set_anchors_preset(Control.PRESET_TOP_WIDE)
	s.position = Vector2(0, 52)
	cont.add_child(s)
	return cont

func _armar_camino() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 78
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)

	var lienzo := Control.new()  # lienzo de posiciones absolutas (para el camino)
	lienzo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(lienzo)

	var unidades: Array = Content.get_unidades()
	var avance: Dictionary = SaveData.get_value("lessons", {})
	var flat: Array = Content.todos_los_ids()  # orden global para el desbloqueo

	var paso := 168.0
	var cx := 360.0
	var amplitud := 150.0
	var y := 12.0
	var gi := 0  # índice global del zigzag (continuo entre zonas)
	var nodos: Array = []
	for u in unidades:
		var header := _header_zona(u)
		header.position = Vector2(0, y)
		lienzo.add_child(header)
		y += 96.0
		var n := 1
		for meta in u["lecciones"]:
			var estado := ProgressLogic.estado(meta["id"], flat, avance)
			var nodo: LessonNode = load("res://scenes/map/LessonNode.tscn").instantiate()
			lienzo.add_child(nodo)
			nodo.configurar(meta, estado, int(avance.get(meta["id"], {}).get("stars", 0)), n)
			nodo.pressed.connect(_al_tocar)
			nodo.position = Vector2(cx + amplitud * sin(gi * 0.9) - 110, y)
			nodo.custom_minimum_size = Vector2(220, 0)
			nodos.append(nodo)
			y += paso
			gi += 1
			n += 1
		y += 34.0  # aire entre zonas

	lienzo.custom_minimum_size = Vector2(720, y + 40)
	_dibujar_camino(lienzo, nodos)

func _dibujar_camino(lienzo: Control, nodos: Array) -> void:
	# El camino se dibuja tras el layout (los centros de los botones ya existen).
	# Engine.get_main_loop() nunca es null (get_tree() sí lo es bajo el runner -s).
	var arbol := Engine.get_main_loop() as SceneTree
	await arbol.process_frame
	await arbol.process_frame
	if nodos.is_empty() or not is_instance_valid(lienzo) or not lienzo.is_inside_tree():
		return
	var linea := Line2D.new()
	linea.width = 12.0
	linea.default_color = Color(UiTheme.ACENTO.r, UiTheme.ACENTO.g, UiTheme.ACENTO.b, 0.22)
	linea.joint_mode = Line2D.LINE_JOINT_ROUND
	linea.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linea.end_cap_mode = Line2D.LINE_CAP_ROUND
	for nodo in nodos:
		linea.add_point(nodo.centro_boton())
	lienzo.add_child(linea)
	lienzo.move_child(linea, 0)  # detrás de los nodos

func _al_tocar(id: String) -> void:
	var avance: Dictionary = SaveData.get_value("lessons", {})
	var estado := ProgressLogic.estado(id, Content.todos_los_ids(), avance)
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
