extends TestCase
## Tanda 1: registro multi-unidad de Content (zonas, rutas, orden global).

func test_ruta_de_id_parsea_unidad_y_leccion() -> void:
	check_eq(Content._ruta_de("u1l01"), "res://content/unit1/lesson_01.json", "unidad 1")
	check_eq(Content._ruta_de("u2l03"), "res://content/unit2/lesson_03.json", "unidad 2")
	check_eq(Content._ruta_de("u8l10"), "res://content/unit8/lesson_10.json", "unidad 8 boss")

func test_get_unidades_solo_muestra_las_que_tienen_contenido() -> void:
	var us := Content.get_unidades()
	check(us.size() >= 1, "al menos la unidad 1 tiene contenido")
	check_eq(us[0]["num"], 1, "la primera unidad es la 1")
	check_eq(str(us[0]["zona"]), "EL NÚCLEO", "zona correcta")
	check_eq(us[0]["lecciones"].size(), 10, "la unidad 1 tiene 10 lecciones")
	# la última lección de la unidad 1 es el boss
	check_eq(bool(us[0]["lecciones"][9]["boss"]), true, "la lección 10 es boss")

func test_todos_los_ids_arranca_en_u1l01_y_esta_en_orden() -> void:
	var ids := Content.todos_los_ids()
	check(ids.size() >= 10, "hay al menos 10 lecciones")
	check_eq(ids[0], "u1l01", "empieza en la primera lección")
	check_eq(ids[9], "u1l10", "la décima es el boss de la unidad 1")

func test_desbloqueo_cruza_unidades() -> void:
	# Con todo el orden global, la primera lección de una unidad se desbloquea
	# solo cuando la anterior (boss de la unidad previa) está completa.
	var flat := ["u1l09", "u1l10", "u2l01", "u2l02"]
	var avance := {"u1l09": {"stars": 2}}
	check_eq(ProgressLogic.estado("u1l10", flat, avance), "actual", "el boss se habilita al completar lo previo")
	check_eq(ProgressLogic.estado("u2l01", flat, avance), "bloqueada", "la unidad 2 sigue bloqueada")
	avance["u1l10"] = {"stars": 3}  # se aprueba el boss
	check_eq(ProgressLogic.estado("u2l01", flat, avance), "actual", "el boss abre la unidad 2")
