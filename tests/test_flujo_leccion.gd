extends TestCase
## Fase 4: integración del flujo de lección completo, headless.
## La navegación real a "result" NO ocurre bajo el runner (Game.goto retorna
## temprano sin nodo "Main"): acá se verifica el ESTADO (SaveData / Economy /
## Game.params), no la pantalla. Patrón de instanciación: ver test_ui_hud.gd.

const LECCION_ESCENA := "res://scenes/lesson/LessonScreen.tscn"
const RESULT_ESCENA := "res://scenes/ui/ResultScreen.tscn"


func _raiz() -> Node:
	# Bajo el runner (-s, extends SceneTree) el árbol vivo sale de aquí.
	return (Engine.get_main_loop() as SceneTree).root


func _resetear_save() -> void:
	# Determinismo entre corridas: el save de test vuelve SIEMPRE a defaults
	# (SaveData usa user://save_test.json bajo el runner, el real no se toca).
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()


func test_flujo_completo_de_leccion() -> void:
	_resetear_save()
	Game.params = {"lesson_id": "u1l01", "review": false}
	var contenedor := Node.new()
	_raiz().add_child(contenedor)
	var lesson = (load(LECCION_ESCENA) as PackedScene).instantiate()
	contenedor.add_child(lesson)
	if not lesson.is_node_ready():
		# La raíz no está "ready" durante _initialize: se notifica a mano.
		lesson.notification(Node.NOTIFICATION_READY)

	var total: int = lesson.ejercicios.size()
	check_eq(total, 8, "la lección 1 tiene 8 ejercicios")
	check_eq(lesson.indice, 0, "arranca en el ejercicio 0")
	check(lesson._actual != null, "hay un ejercicio en pantalla")
	check_eq(lesson._hud._barra.max_value, float(total), "el Hud conoce el total")
	check_eq(lesson._hud._barra.value, 0.0, "el progreso arranca en 0")
	check_eq(Economy.hearts(), 5, "arranca con 5 corazones")

	# 1) Responder BIEN el primer multiple_choice.
	var ej: ExerciseBase = lesson._actual
	ej._elegir(int(ej.data["correct"]))
	check_eq(lesson.perfectas, 1, "la respuesta correcta suma perfecta")
	check_eq(lesson.combo, 1, "la respuesta correcta sube el combo")
	check_eq(Economy.hearts(), 5, "acertar no resta corazones")
	ej.continue_pressed.emit()
	check_eq(lesson.indice, 1, "CONTINUAR avanza el índice")
	check_eq(lesson._hud._barra.value, 1.0, "el Hud refleja el avance")
	check(lesson._actual != ej, "hay un ejercicio nuevo en pantalla")

	# 2) Responder MAL el segundo: -1 corazón y el combo se corta.
	ej = lesson._actual
	var correcto := int(ej.data["correct"])
	var incorrecto := (correcto + 1) % int(ej.data["options"].size())
	ej._elegir(incorrecto)
	check_eq(lesson.errores, 1, "el error queda contado")
	check_eq(lesson.combo, 0, "el error corta el combo")
	check_eq(Economy.hearts(), 4, "el error resta exactamente 1 corazón")
	check_eq(SaveData.get_value("hearts"), 4, "el corazón perdido se persiste")
	ej.continue_pressed.emit()
	check_eq(lesson.indice, 2, "tras un error también se avanza")

	# 3) Jugar el resto respondiendo bien. Los block_builder (índices 4 y 7)
	#    se saltean solos por el guard (BlockBuilder recién llega en Fase 5).
	var pasos := 0
	var max_combo := 0
	while lesson.indice < total and pasos < 32:
		pasos += 1
		ej = lesson._actual
		check(ej is ExerciseBase, "el ejercicio activo respeta el contrato")
		check_eq(str(ej.data["type"]), "multiple_choice",
			"solo los multiple_choice llegan a pantalla (los bb se saltean)")
		ej._elegir(int(ej.data["correct"]))
		max_combo = maxi(max_combo, lesson.combo)
		ej.continue_pressed.emit()
	check_eq(lesson.indice, total, "la lección recorrió todos los ejercicios")
	check_eq(max_combo, 4, "el combo llegó a 4 (4 aciertos seguidos tras el error)")
	check_eq(lesson._hud._lbl_combo.text, "¡Combo x4!", "el Hud muestra el combo")

	# 4) Al terminar, Economy registró todo en SaveData: 6 multiple_choice
	#    jugados, 5 perfectas y 1 error → XP 10 + 5 (sin bonus), 1 estrella.
	check_eq(lesson.perfectas, 5, "5 de 6 multiple_choice perfectas")
	check_eq(lesson.errores, 1, "1 error en total")
	check_eq(SaveData.get_value("xp_total"), 15, "XP registrado: 10 base + 5 perfectas")
	var lecciones: Dictionary = SaveData.get_value("lessons", {})
	check_eq(lecciones.get("u1l01", {}).get("stars", -1), 1, "con errores queda 1 estrella")
	check_eq(SaveData.get_value("streak_days"), 1, "primera actividad: racha 1")
	check_eq(SaveData.get_value("last_activity_date"),
		Time.get_date_string_from_system(), "la actividad quedó fechada hoy")
	check_eq(int(Game.params.get("xp", -1)), 15, "el resumen viajó en Game.params")
	check_eq(int(Game.params.get("estrellas", -1)), 1, "estrellas en el resumen")
	check_eq(bool(Game.params.get("sumo_racha", false)), true, "hoy sumó racha")

	# 5) ResultScreen se construye headless con ese resumen sin reventar.
	var result = (load(RESULT_ESCENA) as PackedScene).instantiate()
	contenedor.add_child(result)
	if not result.is_node_ready():
		result.notification(Node.NOTIFICATION_READY)
	check(result.get_child_count() >= 2, "ResultScreen construyó su UI (fondo + caja)")

	# free() inmediato (no queue_free): si quedaran en el árbol, el _ready real
	# que Godot dispara al terminar _initialize los inicializaría por segunda vez.
	contenedor.free()
	_resetear_save()  # no dejar estado colgado para la corrida siguiente
