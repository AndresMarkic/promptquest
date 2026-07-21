class_name BlockLogic
## Lógica pura del ejercicio de bloques (spec §5.4): mezcla y verificación.

static func armar_pool(solucion: Array, distractores: Array, semilla: int) -> Array:
	var pool := solucion.duplicate()
	pool.append_array(distractores)
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	# Fisher-Yates con rng propio para que los tests sean deterministas.
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	return pool

static func es_correcta(seleccion: Array, solucion: Array) -> bool:
	return seleccion == solucion
