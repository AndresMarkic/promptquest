extends TestCase

func test_xp_leccion_normal() -> void:
	# 8 perfectas, 0 errores: 10 base + 8 + 5 bonus = 23
	check_eq(EconomyRules.xp_por_leccion(8, 0, false), 23, "lección perfecta")
	# 5 perfectas, 2 errores: 10 + 5, sin bonus = 15
	check_eq(EconomyRules.xp_por_leccion(5, 2, false), 15, "lección con errores")

func test_xp_boss_duplica_base() -> void:
	# boss: 20 base + 12 + 5 = 37
	check_eq(EconomyRules.xp_por_leccion(12, 0, true), 37, "boss perfecto")

func test_estrellas() -> void:
	check_eq(EconomyRules.estrellas(0, 120.0), 3, "sin errores y rápida")
	check_eq(EconomyRules.estrellas(0, 200.0), 2, "sin errores pero lenta")
	check_eq(EconomyRules.estrellas(2, 60.0), 1, "con errores")
	check_eq(EconomyRules.estrellas(0, 180.0), 3, "borde exacto 180s da 3")
