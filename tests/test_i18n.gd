extends TestCase

func test_traduce_y_hace_fallback() -> void:
	I18n.idioma_actual = "en"
	check_eq(I18n.t("CONTINUAR"), "CONTINUE", "clave en inglés")
	I18n.idioma_actual = "es"
	check_eq(I18n.t("CONTINUAR"), "CONTINUAR", "clave en español")
	check_eq(I18n.t("NO_EXISTE"), "NO_EXISTE", "clave desconocida devuelve la clave")
	# Dejar el idioma en el default para no afectar a otros tests.
	I18n.idioma_actual = "es"
