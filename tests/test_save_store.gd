extends TestCase

const RUTA := "user://test_save.json"

func _limpiar() -> void:
	if FileAccess.file_exists(RUTA):
		DirAccess.remove_absolute(RUTA)

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

func test_archivo_corrupto_no_crashea() -> void:
	_limpiar()
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	f.store_string("{esto no es json válido")
	f.close()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["hearts"], 5, "corrupto vuelve a defaults")
	_limpiar()
