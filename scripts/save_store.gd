class_name SaveStore
## Única pieza que toca el disco (spec §5.5 y §8). Path inyectable para tests.

const DEFAULTS := {
	"version": 1,
	"language": "es",
	"xp_total": 0,
	"hearts": 5,
	"hearts_regen_unix": 0,
	"streak_days": 0,
	"last_activity_date": "",
	"lessons": {},
	"intro_seen": false,
	"settings": {"sound": true},
}

var path: String
var data: Dictionary

func _init(p_path: String = "user://save.json") -> void:
	path = p_path
	data = _cargar()

func _cargar() -> Dictionary:
	var base: Dictionary = DEFAULTS.duplicate(true)
	if not FileAccess.file_exists(path):
		return base
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return base
	var parseado = JSON.parse_string(f.get_as_text())
	if typeof(parseado) != TYPE_DICTIONARY:
		push_warning("Guardado corrupto en %s: se arranca de cero." % path)
		return base
	_fusionar_profundo(base, parseado)
	return base

static func _fusionar_profundo(base: Dictionary, extra: Dictionary) -> void:
	## Como merge(extra, true) pero recursivo: un save viejo con dicts
	## anidados incompletos (p. ej. "settings": {}) no pierde los defaults.
	for k in extra:
		if base.get(k) is Dictionary and extra[k] is Dictionary:
			_fusionar_profundo(base[k], extra[k])
		else:
			base[k] = extra[k]

func persist() -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo escribir el guardado en " + path)
		return
	f.store_string(JSON.stringify(data, "  "))
