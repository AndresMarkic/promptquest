extends TestCase
## Fase 9: boss cronometrado. El Timer no tickea bajo el runner (-s), así que los
## timeouts se simulan llamando _tiempo_agotado() directo (patrón headless).

const LECCION := "res://scenes/lesson/LessonScreen.tscn"

func _raiz() -> Node:
	return (Engine.get_main_loop() as SceneTree).root

func _resetear() -> void:
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()

func _resolver_bien(ej: ExerciseBase) -> void:
	if str(ej.data["type"]) == "multiple_choice":
		ej._elegir(int(ej.data["correct"]))
	else:
		for texto in ej.data["solution"]:
			for b in ej._pool_cont.get_children():
				if b is Button and b.text == texto and not b.is_queued_for_deletion():
					ej._mover(b, true)
					break
		ej._verificar()

func _abrir_boss(cont: Node) -> Node:
	Game.params = {"lesson_id": "u1l10", "review": false}
	var lesson = (load(LECCION) as PackedScene).instantiate()
	cont.add_child(lesson)
	if not lesson.is_node_ready():
		lesson.notification(Node.NOTIFICATION_READY)
	lesson._cerrar_intro()  # el boss también saluda con byte_intro
	return lesson

func test_boss_es_cronometrado() -> void:
	_resetear()
	var cont := Node.new()
	_raiz().add_child(cont)
	var lesson := _abrir_boss(cont)
	check(lesson.es_boss, "la lección 10 es boss")
	check(lesson._timer != null, "el boss tiene un timer")
	check_eq(lesson.ejercicios.size(), 12, "el boss tiene 12 ejercicios")
	cont.free()
	_resetear()

func test_boss_aprobado_con_pocos_errores() -> void:
	_resetear()
	var cont := Node.new()
	_raiz().add_child(cont)
	var lesson := _abrir_boss(cont)
	var total: int = lesson.ejercicios.size()
	# Los 2 primeros se dejan agotar (2 errores); el resto se resuelve bien.
	var pasos := 0
	while lesson.indice < total and pasos < 40:
		pasos += 1
		if lesson.indice < 2:
			lesson._tiempo_agotado()
		else:
			var ej: ExerciseBase = lesson._actual
			_resolver_bien(ej)
			ej.continue_pressed.emit()
	check_eq(lesson.errores, 2, "2 errores por timeout (≤3 → aprueba)")
	# Aprobado: base doble (20) + 10 perfectas = 30; 1 estrella (hubo errores).
	check_eq(SaveData.get_value("xp_total"), 30, "boss aprobado: XP 20 base + 10 perfectas")
	var lecciones: Dictionary = SaveData.get_value("lessons", {})
	check_eq(lecciones.get("u1l10", {}).get("stars", -1), 1, "con errores, 1 estrella")
	check_eq(bool(Game.params.get("boss", false)), true, "el resumen marca que es boss")
	cont.free()
	_resetear()

func test_boss_fallado_con_muchos_errores() -> void:
	_resetear()
	var cont := Node.new()
	_raiz().add_child(cont)
	var lesson := _abrir_boss(cont)
	var total: int = lesson.ejercicios.size()
	# 4 timeouts = 4 errores > 3 → NO aprueba, no se registra progreso.
	var pasos := 0
	while lesson.indice < total and pasos < 40:
		pasos += 1
		if lesson.indice < 4:
			lesson._tiempo_agotado()
		else:
			var ej: ExerciseBase = lesson._actual
			_resolver_bien(ej)
			ej.continue_pressed.emit()
	check_eq(lesson.errores, 4, "4 errores por timeout")
	check_eq(SaveData.get_value("xp_total"), 0, "boss fallado: no suma XP")
	var lecciones: Dictionary = SaveData.get_value("lessons", {})
	check(not lecciones.has("u1l10"), "boss fallado: no marca la lección completada")
	cont.free()
	_resetear()
