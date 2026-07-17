extends TestCase

func test_localiza_textos_con_fallback() -> void:
	var d := {"es": "Hola", "en": "Hello"}
	check_eq(ContentLoader.localizar(d, "es"), "Hola", "es directo")
	check_eq(ContentLoader.localizar(d, "en"), "Hello", "en directo")
	check_eq(ContentLoader.localizar({"es": "Solo español"}, "en"), "Solo español", "fallback al idioma existente")

func test_localiza_recursivo() -> void:
	var ejercicio := {
		"type": "multiple_choice",
		"question": {"es": "¿Qué es?", "en": "What is it?"},
		"options": [{"es": "A", "en": "Ay"}, {"es": "B", "en": "Bee"}],
		"correct": 1,
	}
	var loc: Dictionary = ContentLoader.localizar(ejercicio, "en")
	check_eq(loc["question"], "What is it?", "pregunta localizada")
	check_eq(loc["options"][0], "Ay", "opción localizada")
	check_eq(loc["correct"], 1, "los no-textos pasan intactos")
	check_eq(loc["type"], "multiple_choice", "strings simples pasan intactos")

func test_validador_detecta_problemas() -> void:
	var mala := {"id": "x", "exercises": [
		{"type": "multiple_choice", "question": {"es": "q"}, "options": [{"es": "a"}], "correct": 5},
		{"type": "block_builder", "goal": {"es": "g"}, "solution": {"es": []}},
		{"type": "desconocido"},
	]}
	var problemas := ContentLoader.validar_leccion(mala)
	check(problemas.size() >= 3, "detecta correct fuera de rango, solution vacía y tipo desconocido; encontró: " + str(problemas))

## Lección completa y válida salvo por los ejercicios que se inyecten,
## para que los tests de tipos no arrastren problemas de campos faltantes.
func _leccion_con(ejercicios) -> Dictionary:
	return {"id": "tipos", "title": {"es": "t", "en": "t"},
		"byte_intro": {"es": "i", "en": "i"}, "byte_outro": {"es": "o", "en": "o"},
		"exercises": ejercicios}

## Si validar_leccion crashea por dentro devuelve null: p sin tipar y
## chequeo explícito de Array para que el rojo sea rojo y no un abort.
func _problemas_de(leccion: Dictionary) -> String:
	var p = ContentLoader.validar_leccion(leccion)
	if not (p is Array):
		return "<CRASH>"
	return " | ".join(p)

func test_validador_rechaza_exercises_que_no_es_array() -> void:
	var msj := _problemas_de(_leccion_con("no soy un array"))
	check(msj != "<CRASH>" and msj.contains("exercises"), "reporta exercises no-Array; obtuve: " + msj)

func test_validador_rechaza_ejercicio_que_no_es_dictionary() -> void:
	var msj := _problemas_de(_leccion_con(["hola", 42]))
	check(msj != "<CRASH>" and msj.contains("ej#0") and msj.contains("ej#1"),
		"reporta ambos items no-Dictionary; obtuve: " + msj)

func test_validador_rechaza_solution_con_tipo_invalido() -> void:
	# solution como String en vez de Dictionary
	var msj := _problemas_de(_leccion_con([
		{"type": "block_builder", "goal": {"es": "g", "en": "g"},
		 "solution": "print(hola)", "explanation": {"es": "e", "en": "e"}}]))
	check(msj != "<CRASH>" and msj.contains("solution"), "reporta solution String; obtuve: " + msj)
	# solution con String por idioma en vez de Array de bloques
	msj = _problemas_de(_leccion_con([
		{"type": "block_builder", "goal": {"es": "g", "en": "g"},
		 "solution": {"es": "print(hola)", "en": "print(hi)"},
		 "explanation": {"es": "e", "en": "e"}}]))
	check(msj != "<CRASH>" and msj.contains("solution"), "reporta solution['es'] String; obtuve: " + msj)

func test_validador_rechaza_tipos_invalidos_en_multiple_choice() -> void:
	# options como String y correct no numérico
	var msj := _problemas_de(_leccion_con([
		{"type": "multiple_choice", "question": {"es": "q", "en": "q"},
		 "options": "a,b,c", "correct": "b",
		 "explanation": {"es": "e", "en": "e"}}]))
	check(msj != "<CRASH>" and msj.contains("options"), "reporta options String; obtuve: " + msj)
	check(msj != "<CRASH>" and msj.contains("correct"), "reporta correct no numérico; obtuve: " + msj)

func test_leccion_valida_pasa() -> void:
	var buena := {"id": "u1l99", "title": {"es": "t", "en": "t"},
		"byte_intro": {"es": "i", "en": "i"}, "byte_outro": {"es": "o", "en": "o"},
		"exercises": [
			{"type": "multiple_choice", "question": {"es": "q", "en": "q"},
			 "options": [{"es": "a", "en": "a"}, {"es": "b", "en": "b"}],
			 "correct": 0, "explanation": {"es": "e", "en": "e"}},
			{"type": "block_builder", "goal": {"es": "g", "en": "g"},
			 "solution": {"es": ["x", "y"], "en": ["x", "y"]},
			 "distractors": {"es": ["z"], "en": ["z"]}, "explanation": {"es": "e", "en": "e"}},
		]}
	check_eq(ContentLoader.validar_leccion(buena), [], "lección bien formada no tiene problemas")
