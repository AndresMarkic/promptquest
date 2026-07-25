extends TestCase

func test_lecciones_existentes_son_validas() -> void:
	var dir := DirAccess.open("res://content/unit2")
	var alguna := false
	for f in dir.get_files():
		if not f.ends_with(".json"):
			continue
		alguna = true
		var l := ContentLoader.cargar_leccion_cruda("res://content/unit2/" + f)
		check(not l.is_empty(), f + ": no parsea")
		var problemas := ContentLoader.validar_leccion(l)
		check(problemas.is_empty(), f + ": " + str(problemas))
	check(alguna, "debe existir al menos una lección")
