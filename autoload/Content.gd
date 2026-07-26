extends Node
## Autoload. Sirve lecciones localizadas y el registro de unidades (zonas).

# Registro de las 8 zonas del camino "de cero a ingeniero". El mapa muestra solo
# las unidades que ya tienen contenido (se van sumando por tandas).
const UNIDADES := [
	{"num": 1, "zona": {"es": "EL NÚCLEO", "en": "THE CORE"}, "sub": {"es": "Fundamentos de IA", "en": "AI Foundations"}, "lecciones": 10, "color": "22c9ff"},
	{"num": 2, "zona": {"es": "LA FORJA", "en": "THE FORGE"}, "sub": {"es": "Prompting Intermedio", "en": "Intermediate Prompting"}, "lecciones": 10, "color": "ff8a3c"},
	{"num": 3, "zona": {"es": "EL TALLER", "en": "THE WORKSHOP"}, "sub": {"es": "Casos de Uso", "en": "Real Use Cases"}, "lecciones": 10, "color": "46e661"},
	{"num": 4, "zona": {"es": "EL OBSERVATORIO", "en": "THE OBSERVATORY"}, "sub": {"es": "Comparar Modelos", "en": "Comparing Models"}, "lecciones": 10, "color": "a06bff"},
	{"num": 5, "zona": {"es": "LA RED", "en": "THE NETWORK"}, "sub": {"es": "Herramientas y Ecosistema", "en": "Tools & Ecosystem"}, "lecciones": 10, "color": "3d7bff"},
	{"num": 6, "zona": {"es": "EL CRISOL", "en": "THE CRUCIBLE"}, "sub": {"es": "Prompt Engineering Avanzado", "en": "Advanced Prompt Engineering"}, "lecciones": 10, "color": "ff4d6d"},
	{"num": 7, "zona": {"es": "LA FÁBRICA", "en": "THE FACTORY"}, "sub": {"es": "IA en Flujos Reales", "en": "AI in Real Workflows"}, "lecciones": 10, "color": "ffb02e"},
	{"num": 8, "zona": {"es": "LA CIMA", "en": "THE SUMMIT"}, "sub": {"es": "Ingeniería de IA", "en": "AI Engineering"}, "lecciones": 10, "color": "ffcf3f", "final": true},
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

## Color de ambiente de la zona a la que pertenece una lección (para teñir el fondo).
func color_de_leccion(id: String) -> Color:
	var num := int(id.substr(1).split("l")[0])
	for u in UNIDADES:
		if int(u["num"]) == num:
			return Color(str(u.get("color", "22c9ff")))
	return Color("22c9ff")

## ¿Es el boss de la última unidad (la marcada "final")? Dispara la certificación.
func es_leccion_final(id: String) -> bool:
	var partes := id.substr(1).split("l")  # "8l10" → ["8","10"]
	var num := int(partes[0])
	var lec := int(partes[1])
	for u in UNIDADES:
		if int(u["num"]) == num:
			return u.get("final", false) and lec == int(u["lecciones"])
	return false

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
		salida.append({"num": u["num"],
			"zona": ContentLoader.localizar(u["zona"], idioma()),
			"sub": ContentLoader.localizar(u["sub"], idioma()),
			"color": u.get("color", "22c9ff"), "final": u.get("final", false),
			"lecciones": lecciones})
	return salida

## Lista plana de ids de todas las lecciones existentes, en orden (para el
## desbloqueo lineal: el boss de una unidad abre la primera de la siguiente).
func todos_los_ids() -> Array:
	var ids := []
	for u in get_unidades():
		for l in u["lecciones"]:
			ids.append(l["id"])
	return ids
