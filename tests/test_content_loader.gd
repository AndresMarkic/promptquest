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
