extends TestCase
## Fase 7: intro narrativa, panel de ajustes y cambio de idioma de la UI.

func _raiz() -> Node:
	return (Engine.get_main_loop() as SceneTree).root

func _instanciar(ruta: String, cont: Node) -> Node:
	var n = (load(ruta) as PackedScene).instantiate()
	cont.add_child(n)
	if not n.is_node_ready():
		n.notification(Node.NOTIFICATION_READY)
	return n

func test_intro_se_construye_y_avanza() -> void:
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()
	I18n.idioma_actual = "es"
	var cont := Node.new()
	_raiz().add_child(cont)
	var intro := _instanciar("res://scenes/intro/IntroScreen.tscn", cont)
	check_eq(intro.pagina, 0, "arranca en la página 0")
	check_eq(intro._lbl.text, I18n.t("INTRO_1"), "muestra el primer texto")
	intro._avanzar()
	check_eq(intro.pagina, 1, "avanza de página")
	check_eq(intro._lbl.text, I18n.t("INTRO_2"), "muestra el segundo texto")
	intro._avanzar()  # página 2
	intro._avanzar()  # página 3 → _terminar marca intro vista
	check_eq(SaveData.get_value("intro_seen"), true, "terminar la intro la marca vista")
	cont.free()

func test_settings_se_construye() -> void:
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()
	var cont := Node.new()
	_raiz().add_child(cont)
	var panel := _instanciar("res://scenes/ui/SettingsPanel.tscn", cont)
	check(panel.get_child_count() >= 2, "el panel de ajustes construyó su UI")
	cont.free()

func test_idioma_cambia_los_textos_de_ui() -> void:
	I18n.idioma_actual = "es"
	var es := I18n.t("LECCION_COMPLETADA")
	I18n.idioma_actual = "en"
	var en := I18n.t("LECCION_COMPLETADA")
	check(es != en, "el texto cambia entre idiomas")
	check_eq(en, "Lesson complete!", "traducción al inglés correcta")
	I18n.idioma_actual = "es"  # dejar el default para otros tests
