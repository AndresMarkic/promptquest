extends TestCase

func test_pool_mezclado_contiene_todo() -> void:
	var pool := BlockLogic.armar_pool(["a", "b", "c"], ["x", "y"], 1234)
	check_eq(pool.size(), 5, "solución + distractores")
	for bloque in ["a", "b", "c", "x", "y"]:
		check(pool.has(bloque), "falta el bloque " + bloque)

func test_pool_es_deterministico_con_semilla() -> void:
	var p1 := BlockLogic.armar_pool(["a", "b", "c"], ["x"], 42)
	var p2 := BlockLogic.armar_pool(["a", "b", "c"], ["x"], 42)
	check_eq(p1, p2, "misma semilla, mismo orden")

func test_verificacion_orden_exacto() -> void:
	var sol := ["Escribí", "una receta", "de pizza."]
	check_eq(BlockLogic.es_correcta(["Escribí", "una receta", "de pizza."], sol), true, "orden exacto")
	check_eq(BlockLogic.es_correcta(["una receta", "Escribí", "de pizza."], sol), false, "orden cambiado")
	check_eq(BlockLogic.es_correcta(["Escribí", "una receta"], sol), false, "incompleta")
	check_eq(BlockLogic.es_correcta(["Escribí", "una receta", "de pizza.", "extra"], sol), false, "de más")
