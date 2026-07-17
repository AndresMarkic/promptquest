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

static func corazones_tras_regen(corazones: int, ultimo_unix: int, ahora_unix: int) -> Dictionary:
	## Devuelve {"corazones": int, "ultimo_unix": int} aplicando la regen por tiempo.
	if corazones >= MAX_CORAZONES:
		return {"corazones": MAX_CORAZONES, "ultimo_unix": ahora_unix}
	var transcurrido := ahora_unix - ultimo_unix
	if transcurrido < 0:
		return {"corazones": corazones, "ultimo_unix": ahora_unix}
	var ganados := int(transcurrido / SEGUNDOS_REGEN)
	var nuevos: int = mini(MAX_CORAZONES, corazones + ganados)
	if nuevos >= MAX_CORAZONES:
		return {"corazones": MAX_CORAZONES, "ultimo_unix": ahora_unix}
	return {"corazones": nuevos, "ultimo_unix": ahora_unix - (transcurrido % SEGUNDOS_REGEN)}

static func _dias_entre(fecha_a: String, fecha_b: String) -> int:
	var ua := Time.get_unix_time_from_datetime_string(fecha_a + "T00:00:00")
	var ub := Time.get_unix_time_from_datetime_string(fecha_b + "T00:00:00")
	return int((ub - ua) / 86400)

static func racha_tras_actividad(racha: int, ultima_fecha: String, hoy: String) -> int:
	## Nueva racha al completar una lección hoy.
	if ultima_fecha == "":
		return 1
	var dias := _dias_entre(ultima_fecha, hoy)
	if dias == 0:
		return maxi(racha, 1)
	if dias == 1:
		return racha + 1
	return 1

static func racha_vigente(racha: int, ultima_fecha: String, hoy: String) -> int:
	## Racha para MOSTRAR (sin jugar): 0 si se rompió.
	if ultima_fecha == "":
		return 0
	return racha if _dias_entre(ultima_fecha, hoy) <= 1 else 0
