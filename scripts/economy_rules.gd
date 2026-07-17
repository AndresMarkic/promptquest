class_name EconomyRules
## Reglas puras de la economía (spec §2.2). Sin estado, sin disco, sin nodos.

const XP_LECCION := 10
const XP_LECCION_BOSS := 20
const XP_RESPUESTA_PERFECTA := 1
const XP_BONUS_SIN_ERRORES := 5
const MAX_CORAZONES := 5
const SEGUNDOS_REGEN := 30 * 60
const SEGUNDOS_TRES_ESTRELLAS := 180.0

static func xp_por_leccion(perfectas: int, errores: int, es_boss: bool) -> int:
	var xp := (XP_LECCION_BOSS if es_boss else XP_LECCION)
	xp += perfectas * XP_RESPUESTA_PERFECTA
	if errores == 0:
		xp += XP_BONUS_SIN_ERRORES
	return xp

static func estrellas(errores: int, segundos: float) -> int:
	if errores > 0:
		return 1
	return 3 if segundos <= SEGUNDOS_TRES_ESTRELLAS else 2
