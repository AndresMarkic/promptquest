extends Node
## Autoload. Estado vivo de la economía; delega los cálculos en EconomyRules.

signal hearts_changed(corazones: int)
signal xp_changed(xp_total: int)

func _ready() -> void:
	_aplicar_regen()

func _aplicar_regen() -> void:
	var r := EconomyRules.corazones_tras_regen(
		SaveData.get_value("hearts", 5),
		SaveData.get_value("hearts_regen_unix", 0),
		int(Time.get_unix_time_from_system()))
	SaveData.set_value("hearts", r["corazones"])
	SaveData.set_value("hearts_regen_unix", r["ultimo_unix"])

func hearts() -> int:
	_aplicar_regen()
	return SaveData.get_value("hearts", 5)

func xp_total() -> int:
	return SaveData.get_value("xp_total", 0)

func racha() -> int:
	return EconomyRules.racha_vigente(
		SaveData.get_value("streak_days", 0),
		SaveData.get_value("last_activity_date", ""),
		Time.get_date_string_from_system())

func can_start_lesson() -> bool:
	return hearts() > 0

func perder_corazon() -> void:
	var h: int = maxi(0, hearts() - 1)
	if h == EconomyRules.MAX_CORAZONES - 1:
		# recién baja del máximo: arranca el reloj de regen
		SaveData.set_value("hearts_regen_unix", int(Time.get_unix_time_from_system()))
	SaveData.set_value("hearts", h)
	hearts_changed.emit(h)

func recuperar_corazon() -> void:
	var h: int = mini(EconomyRules.MAX_CORAZONES, hearts() + 1)
	SaveData.set_value("hearts", h)
	hearts_changed.emit(h)

func on_lesson_finished(lesson_id: String, perfectas: int, errores: int, segundos: float, es_repaso: bool, es_boss: bool) -> Dictionary:
	## Aplica XP, estrellas y racha. Devuelve un resumen para ResultScreen.
	var xp := EconomyRules.xp_por_leccion(perfectas, errores, es_boss)
	var estrellas := EconomyRules.estrellas(errores, segundos)
	SaveData.set_value("xp_total", xp_total() + xp)
	var lecciones: Dictionary = SaveData.get_value("lessons", {})
	var previas: int = lecciones.get(lesson_id, {}).get("stars", 0)
	lecciones[lesson_id] = {"stars": maxi(previas, estrellas)}
	SaveData.set_value("lessons", lecciones)
	var hoy := Time.get_date_string_from_system()
	var racha_nueva := EconomyRules.racha_tras_actividad(
		SaveData.get_value("streak_days", 0),
		SaveData.get_value("last_activity_date", ""), hoy)
	var sumo_racha: bool = racha_nueva > EconomyRules.racha_vigente(
		SaveData.get_value("streak_days", 0),
		SaveData.get_value("last_activity_date", ""), hoy)
	SaveData.set_value("streak_days", racha_nueva)
	SaveData.set_value("last_activity_date", hoy)
	if es_repaso:
		recuperar_corazon()
	xp_changed.emit(xp_total())
	return {"xp": xp, "estrellas": estrellas, "racha": racha_nueva, "sumo_racha": sumo_racha}
