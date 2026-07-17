class_name ContentLoader
## Carga, localiza y valida el contenido JSON de lecciones (spec §5.4).

static func localizar(valor, idioma: String):
	if typeof(valor) == TYPE_DICTIONARY:
		if valor.has("es") or valor.has("en"):
			if valor.has(idioma):
				return valor[idioma]
			return valor.values()[0]  # fallback: el idioma que exista
		var out := {}
		for k in valor:
			out[k] = localizar(valor[k], idioma)
		return out
	if typeof(valor) == TYPE_ARRAY:
		var arr := []
		for v in valor:
			arr.append(localizar(v, idioma))
		return arr
	return valor

static func cargar_leccion_cruda(ruta: String) -> Dictionary:
	## Lee el JSON sin localizar. {} si no existe o está roto (nunca crashea).
	if not FileAccess.file_exists(ruta):
		push_warning("No existe la lección: " + ruta)
		return {}
	var parseado = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parseado) != TYPE_DICTIONARY:
		push_warning("JSON inválido en: " + ruta)
		return {}
	return parseado

static func validar_leccion(leccion: Dictionary) -> Array[String]:
	var problemas: Array[String] = []
	var lid: String = str(leccion.get("id", "?"))
	for campo in ["id", "title", "byte_intro", "byte_outro", "exercises"]:
		if not leccion.has(campo):
			problemas.append("%s: falta el campo '%s'" % [lid, campo])
	var i := 0
	for ej in leccion.get("exercises", []):
		var tag := "%s ej#%d" % [lid, i]
		match ej.get("type", ""):
			"multiple_choice":
				var ops: Array = ej.get("options", [])
				if ops.size() < 2:
					problemas.append(tag + ": menos de 2 opciones")
				var c: int = int(ej.get("correct", -1))
				if c < 0 or c >= ops.size():
					problemas.append(tag + ": 'correct' fuera de rango")
				for req in ["question", "explanation"]:
					if not ej.has(req):
						problemas.append(tag + ": falta '" + req + "'")
			"block_builder":
				var sol: Dictionary = ej.get("solution", {})
				for lang in ["es", "en"]:
					if sol.get(lang, []).is_empty():
						problemas.append(tag + ": solution vacía o falta idioma '" + lang + "'")
				for req in ["goal", "explanation"]:
					if not ej.has(req):
						problemas.append(tag + ": falta '" + req + "'")
			_:
				problemas.append(tag + ": tipo desconocido '" + str(ej.get("type", "")) + "'")
		i += 1
	return problemas
