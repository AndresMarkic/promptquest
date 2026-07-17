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

func test_regen_corazones() -> void:
	var r := EconomyRules.corazones_tras_regen(3, 1000, 1000 + 30 * 60)
	check_eq(r["corazones"], 4, "30 min regeneran 1")
	r = EconomyRules.corazones_tras_regen(3, 1000, 1000 + 75 * 60)
	check_eq(r["corazones"], 5, "75 min regeneran 2")
	check_eq(r["ultimo_unix"], 1000 + 75 * 60, "al llegar al máximo el reloj se resetea a ahora")
	r = EconomyRules.corazones_tras_regen(1, 1000, 1000 + 45 * 60)
	check_eq(r["corazones"], 2, "45 min regeneran 1")
	check_eq(r["ultimo_unix"], 1000 + 30 * 60, "los 15 min sobrantes se conservan")

func test_regen_no_pasa_del_maximo_ni_rompe_con_reloj_atrasado() -> void:
	var r := EconomyRules.corazones_tras_regen(5, 1000, 999999)
	check_eq(r["corazones"], 5, "lleno se queda lleno")
	r = EconomyRules.corazones_tras_regen(2, 5000, 1000)  # reloj hacia atrás
	check_eq(r["corazones"], 2, "reloj atrasado no regala ni quita")
	check_eq(r["ultimo_unix"], 1000, "reloj atrasado resetea el timestamp")

func test_racha() -> void:
	check_eq(EconomyRules.racha_tras_actividad(0, "", "2026-07-17"), 1, "primera vez")
	check_eq(EconomyRules.racha_tras_actividad(3, "2026-07-17", "2026-07-17"), 3, "misma fecha no suma")
	check_eq(EconomyRules.racha_tras_actividad(3, "2026-07-16", "2026-07-17"), 4, "día consecutivo suma")
	check_eq(EconomyRules.racha_tras_actividad(9, "2026-07-14", "2026-07-17"), 1, "racha rota arranca en 1")

func test_racha_vigente_para_mostrar() -> void:
	check_eq(EconomyRules.racha_vigente(5, "2026-07-16", "2026-07-17"), 5, "ayer jugó: sigue viva")
	check_eq(EconomyRules.racha_vigente(5, "2026-07-14", "2026-07-17"), 0, "más de un día sin jugar: muerta")

func test_racha_con_reloj_hacia_atras_se_trata_como_mismo_dia() -> void:
	# ultima_fecha > hoy (el usuario atrasó el reloj): ni suma ni rompe.
	check_eq(EconomyRules.racha_tras_actividad(5, "2026-07-18", "2026-07-17"), 5, "reloj atrasado conserva la racha")
	check_eq(EconomyRules.racha_tras_actividad(0, "2026-07-18", "2026-07-17"), 1, "reloj atrasado con racha 0 arranca en 1")
	check_eq(EconomyRules.racha_tras_actividad(5, "2026-08-01", "2026-07-17"), 5, "varios días hacia atrás tampoco rompe")
	check_eq(EconomyRules.racha_vigente(5, "2026-07-18", "2026-07-17"), 5, "para mostrar tampoco se rompe")
