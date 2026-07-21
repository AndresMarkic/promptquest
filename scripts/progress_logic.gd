class_name ProgressLogic
## Desbloqueo lineal (spec §2.3): completada (≥1 estrella) | actual | bloqueada.

static func estado(id: String, ids_en_orden: Array, avance: Dictionary) -> String:
	if int(avance.get(id, {}).get("stars", 0)) > 0:
		return "completada"
	for otro in ids_en_orden:
		if otro == id:
			return "actual"  # es la primera no completada
		if int(avance.get(otro, {}).get("stars", 0)) == 0:
			return "bloqueada"  # hay una anterior sin completar
	return "bloqueada"
