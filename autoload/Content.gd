extends Node
## Autoload. Sirve lecciones localizadas y el registro de unidades (zonas).

# Registro de las 8 zonas del camino "de cero a ingeniero". El mapa muestra solo
# las unidades que ya tienen contenido (se van sumando por tandas).
const UNIDADES := [
	{"num": 1, "zona": "EL NÚCLEO", "sub": "Fundamentos de IA", "lecciones": 10},
	{"num": 2, "zona": "LA FORJA", "sub": "Prompting Intermedio", "lecciones": 10},
	{"num": 3, "zona": "EL TALLER", "sub": "Casos de Uso", "lecciones": 10},
	{"num": 4, "zona": "EL OBSERVATORIO", "sub": "Comparar Modelos", "lecciones": 10},
	{"num": 5, "zona": "LA RED", "sub": "Herramientas y Ecosistema", "lecciones": 10},
	{"num": 6, "zona": "EL CRISOL", "sub": "Prompt Engineering Avanzado", "lecciones": 10},
	{"num": 7, "zona": "LA FÁBRICA", "sub": "IA en Flujos Reales", "lecciones": 10},
	{"num": 8, "zona": "LA CIMA", "sub": "Ingeniería de IA", "lecciones": 10, "final": true},
]

func idioma() -> String:
	return SaveData.get_value("language", "es")

func set_idioma(codigo: String) -> void:
	SaveData.set_value("language", codigo)
	I18n.idioma_actual = codigo
	TranslationServer.set_locale(codigo)

static func _ruta_de(id: String) -> String:
	# id "u2l03" → content/unit2/lesson_03.json
	var partes := id.substr(1).split("l")  # ["2", "03"]
	return "res://content/unit%s/lesson_%s.json" % [partes[0], partes[1]]

func get_lesson(id: String) -> Dictionary:
	var cruda := ContentLoader.cargar_leccion_cruda(_ruta_de(id))
	return ContentLoader.localizar(cruda, idioma())

func _lesson_id(unidad: int, num: int) -> String:
	return "u%dl%02d" % [unidad, num]

## Unidades con contenido existente: [{num, zona, sub, final, lecciones:[{id,title,boss}]}]
func get_unidades() -> Array:
	var salida := []
	for u in UNIDADES:
		var lecciones := []
		for n in range(1, int(u["lecciones"]) + 1):
			var id := _lesson_id(int(u["num"]), n)
			# Chequeo de existencia (silencioso): las unidades futuras aún no
			# tienen archivos; las lecciones son contiguas, así que al faltar una
			# se corta. Evita el spam de warnings de "no existe la lección".
			if not FileAccess.file_exists(_ruta_de(id)):
				break
			var l := get_lesson(id)
			if l.is_empty():
				break
			lecciones.append({"id": id, "title": l.get("title", id), "boss": l.get("boss", false)})
		if lecciones.is_empty():
			continue  # unidad todavía sin contenido: no se muestra
		salida.append({"num": u["num"], "zona": u["zona"], "sub": u["sub"],
			"final": u.get("final", false), "lecciones": lecciones})
	return salida

## Lista plana de ids de todas las lecciones existentes, en orden (para el
## desbloqueo lineal: el boss de una unidad abre la primera de la siguiente).
func todos_los_ids() -> Array:
	var ids := []
	for u in get_unidades():
		for l in u["lecciones"]:
			ids.append(l["id"])
	return ids
