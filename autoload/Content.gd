extends Node
## Autoload. Sirve lecciones localizadas al idioma activo.

const UNIT1_IDS := ["u1l01", "u1l02", "u1l03", "u1l04", "u1l05",
	"u1l06", "u1l07", "u1l08", "u1l09", "u1l10"]

func idioma() -> String:
	return SaveData.get_value("language", "es")

func set_idioma(codigo: String) -> void:
	SaveData.set_value("language", codigo)
	TranslationServer.set_locale(codigo)

func get_lesson(id: String) -> Dictionary:
	var cruda := ContentLoader.cargar_leccion_cruda("res://content/unit1/lesson_%s.json" % id.substr(3))
	return ContentLoader.localizar(cruda, idioma())

func get_unit_lessons() -> Array:
	## Metadatos para el mapa: [{id, title, boss}]
	var metas := []
	for id in UNIT1_IDS:
		var l := get_lesson(id)
		if l.is_empty():
			continue
		metas.append({"id": id, "title": l.get("title", id), "boss": l.get("boss", false)})
	return metas
