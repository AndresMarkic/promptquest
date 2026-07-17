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
	## Valida estructura Y tipos. Nunca crashea: contenido roto = problemas listados.
	var problemas: Array[String] = []
	var lid: String = str(leccion.get("id", "?"))
	for campo in ["id", "title", "byte_intro", "byte_outro", "exercises"]:
		if not leccion.has(campo):
			problemas.append("%s: falta el campo '%s'" % [lid, campo])
	var ejercicios = leccion.get("exercises", [])
	if typeof(ejercicios) != TYPE_ARRAY:
		problemas.append("%s: 'exercises' debe ser Array, es %s" % [lid, type_string(typeof(ejercicios))])
		return problemas
	var i := 0
	for ej in ejercicios:
		var tag := "%s ej#%d" % [lid, i]
		i += 1
		if typeof(ej) != TYPE_DICTIONARY:
			problemas.append("%s: el ejercicio debe ser Dictionary, es %s" % [tag, type_string(typeof(ej))])
			continue
		match ej.get("type", ""):
			"multiple_choice":
				var ops = ej.get("options", [])
				if typeof(ops) != TYPE_ARRAY:
					problemas.append("%s: 'options' debe ser Array, es %s" % [tag, type_string(typeof(ops))])
					ops = []
				elif ops.size() < 2:
					problemas.append(tag + ": menos de 2 opciones")
				var c = ej.get("correct", -1)
				if typeof(c) != TYPE_INT and typeof(c) != TYPE_FLOAT:
					problemas.append("%s: 'correct' debe ser un número, es %s" % [tag, type_string(typeof(c))])
				elif int(c) < 0 or int(c) >= ops.size():
					problemas.append(tag + ": 'correct' fuera de rango")
				for req in ["question", "explanation"]:
					if not ej.has(req):
						problemas.append(tag + ": falta '" + req + "'")
			"block_builder":
				var sol = ej.get("solution", {})
				if typeof(sol) != TYPE_DICTIONARY:
					problemas.append("%s: 'solution' debe ser Dictionary de idiomas, es %s" % [tag, type_string(typeof(sol))])
				else:
					for lang in ["es", "en"]:
						var bloques = sol.get(lang, [])
						if typeof(bloques) != TYPE_ARRAY:
							problemas.append("%s: solution['%s'] debe ser Array, es %s" % [tag, lang, type_string(typeof(bloques))])
						elif bloques.is_empty():
							problemas.append(tag + ": solution vacía o falta idioma '" + lang + "'")
				for req in ["goal", "explanation"]:
					if not ej.has(req):
						problemas.append(tag + ": falta '" + req + "'")
			_:
				problemas.append(tag + ": tipo desconocido '" + str(ej.get("type", "")) + "'")
	return problemas
