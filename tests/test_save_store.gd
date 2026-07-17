extends TestCase

const RUTA := "user://test_save.json"

func _limpiar() -> void:
	for ruta in [RUTA, RUTA + ".tmp"]:
		if FileAccess.file_exists(ruta):
			DirAccess.remove_absolute(ruta)

func test_sin_archivo_usa_defaults() -> void:
	_limpiar()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["hearts"], 5, "corazones default")
	check_eq(s.data["language"], "es", "idioma default")
	check_eq(s.data["lessons"], {}, "sin lecciones")

func test_persistir_y_recargar() -> void:
	_limpiar()
	var s := SaveStore.new(RUTA)
	s.data["xp_total"] = 42
	s.data["lessons"]["u1l01"] = {"stars": 2}
	s.persist()
	var s2 := SaveStore.new(RUTA)
	check_eq(s2.data["xp_total"], 42, "xp recargado")
	check_eq(s2.data["lessons"]["u1l01"]["stars"], 2, "estrellas recargadas")
	_limpiar()

func test_save_viejo_conserva_defaults_anidados() -> void:
	_limpiar()
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	f.store_string('{"xp_total": 7, "settings": {}}')
	f.close()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["xp_total"], 7, "lo guardado se respeta")
	# .get() y no []: si falta la clave, [] aborta el test y el runner lo daría por OK.
	check_eq(s.data["settings"].get("sound"), true, "default anidado sobrevive un save viejo")
	_limpiar()

func test_valor_anidado_guardado_le_gana_al_default() -> void:
	_limpiar()
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	f.store_string('{"settings": {"sound": false}}')
	f.close()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["settings"].get("sound"), false, "el valor guardado pisa el default anidado")
	_limpiar()

func test_persist_no_deja_tmp_y_el_contenido_es_valido() -> void:
	_limpiar()
	var s := SaveStore.new(RUTA)
	s.data["xp_total"] = 9
	s.persist()
	check(FileAccess.file_exists(RUTA), "el save existe tras persist")
	check(not FileAccess.file_exists(RUTA + ".tmp"), "no queda .tmp residual")
	var parseado = JSON.parse_string(FileAccess.get_file_as_string(RUTA))
	check_eq(typeof(parseado), TYPE_DICTIONARY, "el archivo final es JSON válido")
	_limpiar()

func test_persist_sobre_archivo_existente_lo_reemplaza() -> void:
	# En Windows, renombrar sobre un archivo existente es el paso frágil del
	# patrón atómico: este test lo cubre explícitamente.
	_limpiar()
	var s := SaveStore.new(RUTA)
	s.data["xp_total"] = 1
	s.persist()
	s.data["xp_total"] = 2
	s.persist()
	var s2 := SaveStore.new(RUTA)
	check_eq(int(s2.data["xp_total"]), 2, "el segundo persist pisa al primero")
	check(not FileAccess.file_exists(RUTA + ".tmp"), "sin .tmp tras reemplazar")
	_limpiar()

func test_archivo_corrupto_no_crashea() -> void:
	_limpiar()
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	f.store_string("{esto no es json válido")
	f.close()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["hearts"], 5, "corrupto vuelve a defaults")
	_limpiar()
