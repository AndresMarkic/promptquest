extends TestCase
## Valida TODAS las lecciones de TODAS las unidades existentes (content/unitN/*.json).
## Cubre las unidades nuevas automáticamente a medida que se agregan.

func test_todas_las_lecciones_son_validas() -> void:
	var raiz := DirAccess.open("res://content")
	check(raiz != null, "existe la carpeta content")
	if raiz == null:
		return
	var total := 0
	for carpeta in raiz.get_directories():
		var dir := DirAccess.open("res://content/" + carpeta)
		if dir == null:
			continue
		for f in dir.get_files():
			if not f.ends_with(".json"):
				continue
			total += 1
			var ruta := "res://content/%s/%s" % [carpeta, f]
			var l := ContentLoader.cargar_leccion_cruda(ruta)
			check(not l.is_empty(), ruta + ": no parsea")
			var problemas := ContentLoader.validar_leccion(l)
			check(problemas.is_empty(), ruta + ": " + str(problemas))
	check(total >= 20, "hay al menos las unidades 1 y 2 (20 lecciones), encontró %d" % total)

func test_cada_unidad_tiene_su_boss() -> void:
	# La última lección de cada unidad con contenido debe ser un boss.
	for u in Content.get_unidades():
		var lecs: Array = u["lecciones"]
		check(lecs.size() >= 1, "unidad %s con lecciones" % str(u["num"]))
		check(bool(lecs[lecs.size() - 1]["boss"]),
			"la última lección de la unidad %s es boss" % str(u["num"]))
