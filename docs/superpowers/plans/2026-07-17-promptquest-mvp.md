# PromptQuest MVP — Plan de Implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** MVP jugable de PromptQuest: juego 2D estilo Duolingo en Godot 4.6.3 que enseña Fundamentos de IA (10 lecciones ES/EN, 2 tipos de ejercicio, XP/vidas/racha), 100% local, exportable a Android.

**Architecture:** Lógica de juego en clases puras testeables (`scripts/`) envueltas por 4 autoloads (`SaveData`, `Economy`, `Content`, `Game`). UI construida por código (Control nodes en `_ready()`) sobre escenas `.tscn` mínimas. Contenido en JSON bilingüe separado del código. Spec completa: `docs/superpowers/specs/2026-07-17-promptquest-mvp-design.md`.

**Tech Stack:** Godot 4.6.3 stable (GDScript), test harness propio headless, git, export Android (.aab).

---

## Contexto para el ejecutor (leer primero)

- **Directorio del proyecto:** `c:\Users\nodue\OneDrive\Documentos\porfolioidea\duolingoia` — el proyecto Godot vive en la raíz del repo.
- **Ejecutable de Godot** (ya instalado, NO descargar):
  `C:\Users\nodue\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.6.3-stable_win64_console.exe`
- **Correr tests:** `bash tools/test.sh` (creado en Tarea 0.3). **Smoke boot:** `bash tools/smoke.sh` (Tarea 0.2).
- **Regla técnica:** el modo `-s` de Godot NO carga autoloads → los tests unitarios cubren SOLO clases puras con `class_name` (`scripts/`). Los autoloads son cáscaras finas verificadas con el smoke boot.
- **Convención:** código y comentarios en español (el dueño del proyecto tiene nivel básico de Godot). Un commit por tarea, mensaje indicado en cada una.
- Los textos visibles al jugador NUNCA van hardcodeados: UI → `tr("KEY")` con `i18n/ui.csv`; contenido → JSON con campos `es`/`en`.

---

## Fase 0 — Setup del proyecto

### Tarea 0.1 — Git + estructura base

**Archivos:** `.gitignore`, `tools/test.sh`, `tools/smoke.sh`, carpetas.

`.gitignore`:
```gitignore
.godot/
*.tmp
export/*.aab
export/*.apk
*.keystore
```

`tools/godot_path.sh`:
```bash
#!/usr/bin/env bash
# Ruta al Godot 4.6.3 instalado por winget. Cambiar acá si se actualiza Godot.
export GODOT_EXE="$LOCALAPPDATA/Microsoft/WinGet/Packages/GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe/Godot_v4.6.3-stable_win64_console.exe"
```

`tools/test.sh`:
```bash
#!/usr/bin/env bash
# Corre todos los tests headless. Sale con código != 0 si algo falla.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --headless --path . -s res://tests/test_runner.gd
```

`tools/smoke.sh`:
```bash
#!/usr/bin/env bash
# Arranca el juego headless 1 frame y sale: detecta errores de parseo/autoloads.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --headless --path . --quit
```

**Pasos:**
1. `git init` en la raíz; crear los 4 archivos de arriba; crear carpetas vacías `autoload/ scripts/ scenes/ tests/ content/unit1/ i18n/ assets/` (con `.gitkeep` donde haga falta).
2. Verificar: `bash tools/godot_path.sh` no falla y `ls "$GODOT_EXE"` (tras `source`) encuentra el exe.
3. Commit: `chore: estructura inicial del repo y scripts de herramientas`

### Tarea 0.2 — project.godot + escena principal mínima

**Archivos:** `project.godot`, `scenes/main/Main.tscn`, `scenes/main/Main.gd`.

`project.godot`:
```ini
; Engine configuration file.
config_version=5

[application]
config/name="PromptQuest"
run/main_scene="res://scenes/main/Main.tscn"
config/features=PackedStringArray("4.6", "Mobile")

[display]
window/size/viewport_width=720
window/size/viewport_height=1280
window/handheld/orientation=1
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"

[rendering]
renderer/rendering_method="mobile"
renderer/rendering_method.mobile="mobile"
```

`scenes/main/Main.gd`:
```gdscript
extends Control
## Raíz del juego: contiene la pantalla activa. Game (autoload) la reemplaza.

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
```

`scenes/main/Main.tscn`:
```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scenes/main/Main.gd" id="1"]

[node name="Main" type="Control"]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")
```

**Verificar:** `bash tools/smoke.sh` termina sin errores en la salida (exit 0).
**Commit:** `feat: proyecto Godot 4.6 con escena principal vacía`

### Tarea 0.3 — Harness de tests headless

**Archivos:** `tests/test_case.gd`, `tests/test_runner.gd`, `tests/test_harness_smoke.gd`.

`tests/test_case.gd`:
```gdscript
extends RefCounted
class_name TestCase
## Base de todos los tests. Métodos test_* son descubiertos por el runner.

var failures: Array[String] = []

func check(cond: bool, msg: String) -> void:
	if not cond:
		failures.append(msg)

func check_eq(got, want, msg: String = "") -> void:
	if got != want:
		failures.append("%s (esperado: %s | obtuve: %s)" % [msg, str(want), str(got)])
```

`tests/test_runner.gd`:
```gdscript
extends SceneTree
## Corre headless: godot --headless --path . -s res://tests/test_runner.gd

func _initialize() -> void:
	var total := 0
	var fallas := 0
	var dir := DirAccess.open("res://tests")
	var archivos := Array(dir.get_files())
	archivos.sort()
	for f in archivos:
		if not (f.begins_with("test_") and f.ends_with(".gd")):
			continue
		if f in ["test_runner.gd", "test_case.gd"]:
			continue
		var t = load("res://tests/" + f).new()
		for m in t.get_method_list():
			if not m.name.begins_with("test_"):
				continue
			t.failures.clear()
			t.call(m.name)
			total += 1
			if t.failures.is_empty():
				print("OK   %s :: %s" % [f, m.name])
			else:
				fallas += 1
				print("FALLA %s :: %s" % [f, m.name])
				for msg in t.failures:
					print("      - " + msg)
	print("== %d tests, %d fallas ==" % [total, fallas])
	quit(1 if fallas > 0 else 0)
```

`tests/test_harness_smoke.gd`:
```gdscript
extends TestCase

func test_el_harness_funciona() -> void:
	check_eq(1 + 1, 2, "aritmética básica")
```

**Verificar:** `bash tools/test.sh` imprime `OK` y `== 1 tests, 0 fallas ==`, exit 0. Después cambiar temporalmente el `2` por `3`, verificar que sale `FALLA` y exit 1, y revertir.
**Commit:** `feat: harness de tests headless con runner propio`

---

## Fase 1 — Reglas puras del juego (TDD)

### Tarea 1.1 — EconomyRules: XP y estrellas

**Test primero** — `tests/test_economy_rules.gd`:
```gdscript
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
```

Correr `bash tools/test.sh` → debe FALLAR (EconomyRules no existe).

**Implementación** — `scripts/economy_rules.gd`:
```gdscript
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
```

**Verificar:** `bash tools/test.sh` → todo OK.
**Commit:** `feat: reglas de XP y estrellas con tests`

### Tarea 1.2 — EconomyRules: regeneración de corazones

**Test primero** — agregar a `tests/test_economy_rules.gd`:
```gdscript
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
```

Correr tests → FALLA. **Implementación** — agregar a `scripts/economy_rules.gd`:
```gdscript
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
```

**Verificar:** tests OK. **Commit:** `feat: regeneración de corazones por timestamp`

### Tarea 1.3 — EconomyRules: racha diaria

**Test primero** — agregar a `tests/test_economy_rules.gd`:
```gdscript
func test_racha() -> void:
	check_eq(EconomyRules.racha_tras_actividad(0, "", "2026-07-17"), 1, "primera vez")
	check_eq(EconomyRules.racha_tras_actividad(3, "2026-07-17", "2026-07-17"), 3, "misma fecha no suma")
	check_eq(EconomyRules.racha_tras_actividad(3, "2026-07-16", "2026-07-17"), 4, "día consecutivo suma")
	check_eq(EconomyRules.racha_tras_actividad(9, "2026-07-14", "2026-07-17"), 1, "racha rota arranca en 1")

func test_racha_vigente_para_mostrar() -> void:
	check_eq(EconomyRules.racha_vigente(5, "2026-07-16", "2026-07-17"), 5, "ayer jugó: sigue viva")
	check_eq(EconomyRules.racha_vigente(5, "2026-07-14", "2026-07-17"), 0, "más de un día sin jugar: muerta")
```

Correr tests → FALLA. **Implementación** — agregar a `scripts/economy_rules.gd`:
```gdscript
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
```

**Verificar:** tests OK. **Commit:** `feat: lógica de racha diaria`

### Tarea 1.4 — SaveStore: guardado local a prueba de corrupción

**Test primero** — `tests/test_save_store.gd`:
```gdscript
extends TestCase

const RUTA := "user://test_save.json"

func _limpiar() -> void:
	if FileAccess.file_exists(RUTA):
		DirAccess.remove_absolute(RUTA)

func test_sin_archivo_usa_defaults() -> void:
	_limpiar()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["hearts"], 5, "corazones default")
	check_eq(s.data["language"], "es", "idioma default")
	check_eq(s.data["lessons"], {}, "sin lecciones")

func test_persistir_y_recargar() -> void:
	_limpiar()
	var s := SaveStore.new(RUTA)
	s.data["xp_total"] = 42
	s.data["lessons"]["u1l01"] = {"stars": 2}
	s.persist()
	var s2 := SaveStore.new(RUTA)
	check_eq(s2.data["xp_total"], 42, "xp recargado")
	check_eq(s2.data["lessons"]["u1l01"]["stars"], 2, "estrellas recargadas")
	_limpiar()

func test_archivo_corrupto_no_crashea() -> void:
	_limpiar()
	var f := FileAccess.open(RUTA, FileAccess.WRITE)
	f.store_string("{esto no es json válido")
	f.close()
	var s := SaveStore.new(RUTA)
	check_eq(s.data["hearts"], 5, "corrupto vuelve a defaults")
	_limpiar()
```

Correr tests → FALLA. **Implementación** — `scripts/save_store.gd`:
```gdscript
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
	base.merge(parseado, true)
	return base

func persist() -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_warning("No se pudo escribir el guardado en " + path)
		return
	f.store_string(JSON.stringify(data, "  "))
```

**Verificar:** tests OK. **Commit:** `feat: guardado local con defaults y tolerancia a corrupción`

### Tarea 1.5 — ContentLoader: localización y validación de lecciones

**Test primero** — `tests/test_content_loader.gd`:
```gdscript
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
```

Correr tests → FALLA. **Implementación** — `scripts/content_loader.gd`:
```gdscript
class_name ContentLoader
## Carga, localiza y valida el contenido JSON de lecciones (spec §5.4).

static func localizar(valor, idioma: String):
	if typeof(valor) == TYPE_DICTIONARY:
		if valor.has("es") or valor.has("en"):
			if valor.has(idioma):
				return valor[idioma]
			return valor.values()[0]  # fallback: el idioma que exista
		var out := {}
		for k in valor:
			out[k] = localizar(valor[k], idioma)
		return out
	if typeof(valor) == TYPE_ARRAY:
		var arr := []
		for v in valor:
			arr.append(localizar(v, idioma))
		return arr
	return valor

static func cargar_leccion_cruda(ruta: String) -> Dictionary:
	## Lee el JSON sin localizar. {} si no existe o está roto (nunca crashea).
	if not FileAccess.file_exists(ruta):
		push_warning("No existe la lección: " + ruta)
		return {}
	var parseado = JSON.parse_string(FileAccess.get_file_as_string(ruta))
	if typeof(parseado) != TYPE_DICTIONARY:
		push_warning("JSON inválido en: " + ruta)
		return {}
	return parseado

static func validar_leccion(leccion: Dictionary) -> Array[String]:
	var problemas: Array[String] = []
	var lid: String = str(leccion.get("id", "?"))
	for campo in ["id", "title", "byte_intro", "byte_outro", "exercises"]:
		if not leccion.has(campo):
			problemas.append("%s: falta el campo '%s'" % [lid, campo])
	var i := 0
	for ej in leccion.get("exercises", []):
		var tag := "%s ej#%d" % [lid, i]
		match ej.get("type", ""):
			"multiple_choice":
				var ops: Array = ej.get("options", [])
				if ops.size() < 2:
					problemas.append(tag + ": menos de 2 opciones")
				var c: int = int(ej.get("correct", -1))
				if c < 0 or c >= ops.size():
					problemas.append(tag + ": 'correct' fuera de rango")
				for req in ["question", "explanation"]:
					if not ej.has(req):
						problemas.append(tag + ": falta '" + req + "'")
			"block_builder":
				var sol: Dictionary = ej.get("solution", {})
				for lang in ["es", "en"]:
					if sol.get(lang, []).is_empty():
						problemas.append(tag + ": solution vacía o falta idioma '" + lang + "'")
				for req in ["goal", "explanation"]:
					if not ej.has(req):
						problemas.append(tag + ": falta '" + req + "'")
			_:
				problemas.append(tag + ": tipo desconocido '" + str(ej.get("type", "")) + "'")
		i += 1
	return problemas
```

**Verificar:** tests OK. **Commit:** `feat: carga, localización y validación de contenido JSON`

---

## Fase 2 — Autoloads (cáscaras finas)

### Tarea 2.1 — Los 4 autoloads + registro en project.godot

Sin tests unitarios (los autoloads no cargan en modo `-s`): se verifica con `bash tools/smoke.sh` + los tests existentes siguen verdes.

`autoload/SaveData.gd`:
```gdscript
extends Node
## Autoload. Único acceso al guardado. El resto del juego NO toca disco.

var store: SaveStore

func _ready() -> void:
	store = SaveStore.new()

func get_value(clave: String, defecto = null):
	return store.data.get(clave, defecto)

func set_value(clave: String, valor) -> void:
	store.data[clave] = valor
	store.persist()
```

`autoload/Economy.gd`:
```gdscript
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
```

`autoload/Content.gd`:
```gdscript
extends Node
## Autoload. Sirve lecciones localizadas al idioma activo.

const UNIT1_IDS := ["u1l01", "u1l02", "u1l03", "u1l04", "u1l05",
	"u1l06", "u1l07", "u1l08", "u1l09", "u1l10"]

func idioma() -> String:
	return SaveData.get_value("language", "es")

func set_idioma(codigo: String) -> void:
	SaveData.set_value("language", codigo)
	TranslationServer.set_locale(codigo)

func get_lesson(id: String) -> Dictionary:
	var cruda := ContentLoader.cargar_leccion_cruda("res://content/unit1/lesson_%s.json" % id.substr(3))
	return ContentLoader.localizar(cruda, idioma())

func get_unit_lessons() -> Array:
	## Metadatos para el mapa: [{id, title, boss}]
	var metas := []
	for id in UNIT1_IDS:
		var l := get_lesson(id)
		if l.is_empty():
			continue
		metas.append({"id": id, "title": l.get("title", id), "boss": l.get("boss", false)})
	return metas
```

Nota: los archivos se llaman `lesson_01.json` … `lesson_10.json` y los ids son `u1l01` … `u1l10` (por eso `id.substr(3)` → `"01"`).

`autoload/Game.gd`:
```gdscript
extends Node
## Autoload. Navegación entre pantallas (spec §6). Única forma de cambiar pantalla.

const PANTALLAS := {
	"intro": "res://scenes/intro/IntroScreen.tscn",
	"map": "res://scenes/map/MapScreen.tscn",
	"lesson": "res://scenes/lesson/LessonScreen.tscn",
	"result": "res://scenes/ui/ResultScreen.tscn",
}

var params: Dictionary = {}  # parámetros para la pantalla entrante

func _ready() -> void:
	TranslationServer.set_locale(SaveData.get_value("language", "es"))
	# Pantalla inicial: intro la primera vez, mapa después.
	goto.call_deferred("intro" if not SaveData.get_value("intro_seen", false) else "map")

func goto(pantalla: String, p_params: Dictionary = {}) -> void:
	params = p_params
	var main := get_tree().root.get_node("Main")
	for hijo in main.get_children():
		hijo.queue_free()
	var escena: PackedScene = load(PANTALLAS[pantalla])
	main.add_child(escena.instantiate())
```

Registrar en `project.godot` (agregar la sección — el ORDEN importa: SaveData primero):
```ini
[autoload]
SaveData="*res://autoload/SaveData.gd"
Economy="*res://autoload/Economy.gd"
Content="*res://autoload/Content.gd"
Game="*res://autoload/Game.gd"
```

Para que el smoke boot no falle mientras no existen las pantallas, crear stubs mínimos ahora: `scenes/intro/IntroScreen.tscn`, `scenes/map/MapScreen.tscn`, `scenes/lesson/LessonScreen.tscn`, `scenes/ui/ResultScreen.tscn` — cada uno un `Control` raíz sin script (mismo formato .tscn que Main pero sin ExtResource), que las fases 3-7 reemplazan.

**Verificar:** `bash tools/smoke.sh` exit 0 y sin errores de parseo; `bash tools/test.sh` sigue verde. Borrar `%APPDATA%/Godot/app_userdata/PromptQuest/save.json` si quedó de pruebas manuales.
**Commit:** `feat: autoloads SaveData, Economy, Content y Game con navegación`

---

## Fase 3 — Base visual y HUD

Regla de esta fase en adelante: **las escenas .tscn son mínimas** (nodo raíz + script); toda la UI se construye por código en `_ready()`/`_build()`. Formato .tscn idéntico al de `Main.tscn` cambiando nombre y ruta del script. Verificación de pantallas: smoke boot + prueba manual (`bash tools/run.sh`, creado en 3.1).

### Tarea 3.1 — UiTheme + iconos dibujados + run.sh

`tools/run.sh`:
```bash
#!/usr/bin/env bash
# Abre el juego en ventana para probarlo a mano.
cd "$(dirname "$0")/.."
source tools/godot_path.sh
"$GODOT_EXE" --path .
```

`scripts/ui_theme.gd`:
```gdscript
class_name UiTheme
## Paleta y fábrica de controles con estilo consistente. Cero assets externos.

const FONDO := Color("12122b")
const PANEL := Color("1e1e42")
const PRIMARIO := Color("58cc02")      # verde acción (estilo Duolingo)
const PRIMARIO_HOVER := Color("6ee014")
const ACENTO := Color("1cb0f6")        # celeste
const PELIGRO := Color("ff4b4b")
const TEXTO := Color("f5f5ff")
const TEXTO_SUAVE := Color("a0a0c0")
const DORADO := Color("ffc800")

static func fondo_pantalla(raiz: Control) -> void:
	var bg := ColorRect.new()
	bg.color = FONDO
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(bg)
	raiz.move_child(bg, 0)

static func _estilo(color: Color, radio: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radio)
	s.set_content_margin_all(16)
	return s

static func boton(texto: String, color: Color = PRIMARIO) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_stylebox_override("normal", _estilo(color))
	b.add_theme_stylebox_override("hover", _estilo(color.lightened(0.1)))
	b.add_theme_stylebox_override("pressed", _estilo(color.darkened(0.2)))
	b.add_theme_stylebox_override("disabled", _estilo(Color(color, 0.4)))
	b.add_theme_color_override("font_color", Color("0f2a00") if color == PRIMARIO else TEXTO)
	b.add_theme_font_size_override("font_size", 26)
	b.custom_minimum_size = Vector2(0, 64)
	return b

static func etiqueta(texto: String, tam: int = 24, color: Color = TEXTO) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

static func panel(color: Color = PANEL, radio: int = 20) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _estilo(color, radio))
	return p
```

`scripts/icono.gd` — iconos vectoriales propios (el font por defecto no trae emoji, spec §3 arte placeholder):
```gdscript
class_name Icono
extends Control
## Dibuja corazón / fuego / estrella sin assets. tipo: "corazon"|"fuego"|"estrella"

var tipo := "corazon"
var activo := true

static func nuevo(p_tipo: String, p_activo: bool = true, tam: float = 28.0) -> Icono:
	var i := Icono.new()
	i.tipo = p_tipo
	i.activo = p_activo
	i.custom_minimum_size = Vector2(tam, tam)
	return i

func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size / 2.0
	match tipo:
		"corazon":
			var col := UiTheme.PELIGRO if activo else Color("3a3a5c")
			draw_circle(c + Vector2(-s * 0.18, -s * 0.12), s * 0.22, col)
			draw_circle(c + Vector2(s * 0.18, -s * 0.12), s * 0.22, col)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-s * 0.38, -0.02 * s), c + Vector2(s * 0.38, -0.02 * s),
				c + Vector2(0, s * 0.42)]), col)
		"fuego":
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -s * 0.45), c + Vector2(s * 0.32, s * 0.1),
				c + Vector2(0, s * 0.45), c + Vector2(-s * 0.32, s * 0.1)]),
				Color("ff9600") if activo else Color("3a3a5c"))
			draw_circle(c + Vector2(0, s * 0.12), s * 0.16, UiTheme.DORADO if activo else Color("55557a"))
		"estrella":
			var pts := PackedVector2Array()
			for k in 10:
				var ang := -PI / 2 + k * PI / 5.0
				var r := s * (0.48 if k % 2 == 0 else 0.20)
				pts.append(c + Vector2(cos(ang), sin(ang)) * r)
			draw_colored_polygon(pts, UiTheme.DORADO if activo else Color("3a3a5c"))
```

**Verificar:** `bash tools/smoke.sh` sigue exit 0 (las clases parsean); tests verdes.
**Commit:** `feat: paleta, fábrica de UI e iconos vectoriales`

### Tarea 3.2 — HUD de lección

`scenes/ui/Hud.gd` (con su `Hud.tscn` mínimo, raíz `Control`):
```gdscript
extends Control
class_name Hud
## Barra superior de la lección: salir, progreso, corazones, combo.

signal exit_pressed

var _barra: ProgressBar
var _cont_corazones: HBoxContainer
var _lbl_combo: Label

func _ready() -> void:
	custom_minimum_size = Vector2(0, 110)
	var fila := HBoxContainer.new()
	fila.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fila.add_theme_constant_override("separation", 12)
	fila.position = Vector2(16, 16)
	fila.size = Vector2(688, 48)
	add_child(fila)

	var salir := Button.new()
	salir.text = "✕"
	salir.flat = true
	salir.add_theme_font_size_override("font_size", 30)
	salir.pressed.connect(func(): exit_pressed.emit())
	fila.add_child(salir)

	_barra = ProgressBar.new()
	_barra.min_value = 0
	_barra.show_percentage = false
	_barra.custom_minimum_size = Vector2(0, 22)
	_barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var relleno := StyleBoxFlat.new()
	relleno.bg_color = UiTheme.PRIMARIO
	relleno.set_corner_radius_all(11)
	_barra.add_theme_stylebox_override("fill", relleno)
	fila.add_child(_barra)

	_cont_corazones = HBoxContainer.new()
	fila.add_child(_cont_corazones)

	_lbl_combo = UiTheme.etiqueta("", 20, UiTheme.DORADO)
	_lbl_combo.position = Vector2(16, 72)
	add_child(_lbl_combo)

func set_progreso(actual: int, total: int) -> void:
	_barra.max_value = total
	_barra.value = actual

func set_corazones(n: int) -> void:
	for h in _cont_corazones.get_children():
		h.queue_free()
	for k in EconomyRules.MAX_CORAZONES:
		_cont_corazones.add_child(Icono.nuevo("corazon", k < n))

func set_combo(n: int) -> void:
	if n >= 3:
		_lbl_combo.text = tr("COMBO_MSG") % n
	else:
		_lbl_combo.text = ""
```

Crear también `i18n/ui.csv` con las primeras claves (se completa en Tarea 7.3) y registrarlo: en `project.godot` agregar
```ini
[internationalization]
locale/translations=PackedStringArray("res://i18n/ui.en.translation", "res://i18n/ui.es.translation")
```
Nota: Godot genera los `.translation` al importar el CSV **al abrir el editor**. Para no depender del editor en headless, alternativa usada por este plan: NO usar el sistema de Translation de Godot todavía — crear `scripts/i18n.gd` propio (Tarea 7.3) y mientras tanto dejar `tr("COMBO_MSG")` como texto literal `"¡Combo x%d!"`. **Decisión: usar i18n propio en 7.3; hasta entonces textos de UI en español directo.** (El contenido de lecciones ya es bilingüe por JSON desde el día 1.)

**Verificar:** smoke boot OK. **Commit:** `feat: HUD de lección con progreso, corazones y combo`

---

## Fase 4 — Ejercicio de opción múltiple + flujo de lección completo

### Tarea 4.1 — ExerciseBase + MultipleChoice

`scenes/exercises/ExerciseBase.gd`:
```gdscript
class_name ExerciseBase
extends Control
## Contrato de todo ejercicio (spec §5.3):
## setup(data) → el ejercicio se construye; emite answered(correct) UNA vez;
## muestra su feedback y luego emite continue_pressed.

signal answered(correct: bool)
signal continue_pressed

var data: Dictionary
var _respondido := false

func setup(d: Dictionary) -> void:
	data = d
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _build() -> void:
	push_error("ExerciseBase._build() debe sobreescribirse")

func _responder(correcto: bool) -> void:
	if _respondido:
		return
	_respondido = true
	answered.emit(correcto)
	_mostrar_feedback(correcto)

func _mostrar_feedback(correcto: bool) -> void:
	var panel := UiTheme.panel(Color("173d0c") if correcto else Color("4a1220"))
	panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	panel.offset_top = -190
	add_child(panel)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 10)
	panel.add_child(caja)
	caja.add_child(UiTheme.etiqueta("¡Correcto!" if correcto else "Ups, no era así",
		26, UiTheme.PRIMARIO if correcto else UiTheme.PELIGRO))
	caja.add_child(UiTheme.etiqueta(str(data.get("explanation", "")), 20, UiTheme.TEXTO_SUAVE))
	var btn := UiTheme.boton("CONTINUAR", UiTheme.PRIMARIO if correcto else UiTheme.PELIGRO)
	btn.pressed.connect(func(): continue_pressed.emit())
	caja.add_child(btn)
```

`scenes/exercises/MultipleChoice.gd` (con `MultipleChoice.tscn` mínimo, raíz `Control` + script):
```gdscript
extends ExerciseBase
## data: {question: String, options: Array[String], correct: int, explanation: String}

var _botones: Array[Button] = []

func _build() -> void:
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_FULL_RECT)
	caja.offset_left = 24
	caja.offset_right = -24
	caja.offset_top = 130
	caja.add_theme_constant_override("separation", 16)
	add_child(caja)
	caja.add_child(UiTheme.etiqueta(str(data["question"]), 28))
	var i := 0
	for opcion in data["options"]:
		var b := UiTheme.boton(str(opcion), UiTheme.PANEL)
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var indice := i
		b.pressed.connect(func(): _elegir(indice))
		caja.add_child(b)
		_botones.append(b)
		i += 1

func _elegir(indice: int) -> void:
	var correcto: int = int(data["correct"])
	for k in _botones.size():
		_botones[k].disabled = true
	_botones[correcto].add_theme_stylebox_override("disabled",
		UiTheme._estilo(Color("2e6b12")))
	if indice != correcto:
		_botones[indice].add_theme_stylebox_override("disabled",
			UiTheme._estilo(Color("7a1f2b")))
	_responder(indice == correcto)
```

**Verificar:** smoke boot OK (parseo). La verificación funcional llega con 4.3.
**Commit:** `feat: contrato ExerciseBase y ejercicio de opción múltiple`

### Tarea 4.2 — Contenido: lesson_01.json completo (plantilla de todo el contenido)

**Test primero** — `tests/test_contenido_unit1.gd` (valida TODAS las lecciones existentes; crece solo a medida que se agregan archivos):
```gdscript
extends TestCase

func test_lecciones_existentes_son_validas() -> void:
	var dir := DirAccess.open("res://content/unit1")
	var alguna := false
	for f in dir.get_files():
		if not f.ends_with(".json"):
			continue
		alguna = true
		var l := ContentLoader.cargar_leccion_cruda("res://content/unit1/" + f)
		check(not l.is_empty(), f + ": no parsea")
		var problemas := ContentLoader.validar_leccion(l)
		check(problemas.is_empty(), f + ": " + str(problemas))
	check(alguna, "debe existir al menos una lección")
```

Correr → FALLA (carpeta vacía). **Implementación** — `content/unit1/lesson_01.json` (contenido REAL y COMPLETO, es la plantilla de las tareas de la Fase 8):
```json
{
  "id": "u1l01",
  "title": { "es": "¿Qué es la IA generativa?", "en": "What is generative AI?" },
  "byte_intro": {
    "es": "¡Hola! Soy Byte. Perdí mi memoria... ¿me ayudás a recuperarla aprendiendo conmigo?",
    "en": "Hi! I'm Byte. I lost my memory... will you help me recover it by learning with me?"
  },
  "byte_outro": {
    "es": "¡Recuperé mi primer fragmento de memoria! Ya sé qué soy: una IA generativa.",
    "en": "I got my first memory fragment back! Now I know what I am: a generative AI."
  },
  "exercises": [
    {
      "type": "multiple_choice",
      "question": { "es": "¿Qué hace una IA generativa?", "en": "What does a generative AI do?" },
      "options": [
        { "es": "Crea contenido nuevo: texto, imágenes, código", "en": "Creates new content: text, images, code" },
        { "es": "Solo busca páginas en internet", "en": "It only searches web pages" },
        { "es": "Guarda tus archivos en la nube", "en": "It stores your files in the cloud" }
      ],
      "correct": 0,
      "explanation": {
        "es": "Generativa viene de 'generar': produce contenido nuevo en vez de solo buscarlo o guardarlo.",
        "en": "Generative comes from 'generate': it produces new content instead of just finding or storing it."
      }
    },
    {
      "type": "multiple_choice",
      "question": {
        "es": "¿Cuál es la diferencia con un programa tradicional?",
        "en": "How is it different from a traditional program?"
      },
      "options": [
        { "es": "El programa sigue reglas fijas; la IA produce respuestas nuevas según patrones", "en": "A program follows fixed rules; AI produces new answers based on patterns" },
        { "es": "No hay diferencia, son lo mismo", "en": "There is no difference, they are the same" },
        { "es": "La IA es siempre más rápida", "en": "AI is always faster" }
      ],
      "correct": 0,
      "explanation": {
        "es": "Una calculadora siempre da el mismo resultado exacto. Una IA generativa puede responder distinto cada vez, porque genera en base a patrones aprendidos.",
        "en": "A calculator always gives the same exact result. A generative AI can answer differently each time, because it generates based on learned patterns."
      }
    },
    {
      "type": "multiple_choice",
      "question": { "es": "¿Cuál de estos usa IA generativa?", "en": "Which of these uses generative AI?" },
      "options": [
        { "es": "Una calculadora de bolsillo", "en": "A pocket calculator" },
        { "es": "Un chat que escribe un cuento original que le pediste", "en": "A chat that writes an original story you asked for" },
        { "es": "Un reloj despertador", "en": "An alarm clock" }
      ],
      "correct": 1,
      "explanation": {
        "es": "Escribir un cuento que no existía antes es generar contenido nuevo: eso es IA generativa.",
        "en": "Writing a story that didn't exist before is generating new content: that's generative AI."
      }
    },
    {
      "type": "multiple_choice",
      "question": { "es": "¿De dónde saca la IA lo que 'sabe'?", "en": "Where does AI get what it 'knows'?" },
      "options": [
        { "es": "De entrenar con enormes cantidades de texto y datos", "en": "From training on huge amounts of text and data" },
        { "es": "De leer tu mente", "en": "From reading your mind" },
        { "es": "De estar conectada a todos los teléfonos", "en": "From being connected to every phone" }
      ],
      "correct": 0,
      "explanation": {
        "es": "Durante su entrenamiento procesó muchísimo texto y aprendió patrones del lenguaje. No te espía ni adivina: aprendió antes de hablar con vos.",
        "en": "During training it processed massive amounts of text and learned language patterns. It doesn't spy or guess: it learned before ever talking to you."
      }
    },
    {
      "type": "block_builder",
      "goal": {
        "es": "Armá la definición correcta de IA generativa",
        "en": "Build the correct definition of generative AI"
      },
      "solution": {
        "es": ["La IA generativa", "crea contenido nuevo", "a partir de patrones aprendidos."],
        "en": ["Generative AI", "creates new content", "from learned patterns."]
      },
      "distractors": {
        "es": ["copia páginas de internet", "sin aprender nada"],
        "en": ["copies web pages", "without learning anything"]
      },
      "explanation": {
        "es": "Genera (no copia) usando patrones que aprendió en su entrenamiento.",
        "en": "It generates (doesn't copy) using patterns it learned during training."
      }
    },
    {
      "type": "multiple_choice",
      "question": {
        "es": "¿Qué puede hacer una IA generativa y qué no?",
        "en": "What can generative AI do and not do?"
      },
      "options": [
        { "es": "Puede escribir un poema; no puede saber qué hiciste ayer", "en": "It can write a poem; it can't know what you did yesterday" },
        { "es": "Puede leer tu mente; no puede escribir texto", "en": "It can read your mind; it can't write text" },
        { "es": "Puede todo, sin límites", "en": "It can do anything, no limits" }
      ],
      "correct": 0,
      "explanation": {
        "es": "Es muy buena generando contenido, pero no tiene acceso a tu vida ni a información que no le diste.",
        "en": "It's great at generating content, but it has no access to your life or information you didn't give it."
      }
    },
    {
      "type": "multiple_choice",
      "question": {
        "es": "Le pedís lo mismo dos veces a una IA generativa. ¿Qué puede pasar?",
        "en": "You ask a generative AI the same thing twice. What can happen?"
      },
      "options": [
        { "es": "Puede responder distinto cada vez", "en": "It may answer differently each time" },
        { "es": "Responde siempre exactamente igual", "en": "It always answers exactly the same" },
        { "es": "La segunda vez se niega a responder", "en": "The second time it refuses to answer" }
      ],
      "correct": 0,
      "explanation": {
        "es": "Como genera la respuesta en el momento, dos pedidos iguales pueden dar textos diferentes (y ambos válidos).",
        "en": "Since it generates the answer on the spot, two identical requests can produce different (and both valid) texts."
      }
    },
    {
      "type": "block_builder",
      "goal": {
        "es": "Armá un pedido válido para una IA generativa",
        "en": "Build a valid request for a generative AI"
      },
      "solution": {
        "es": ["Escribí", "una receta simple", "de pizza casera."],
        "en": ["Write", "a simple recipe", "for homemade pizza."]
      },
      "distractors": {
        "es": ["Adiviná", "qué cené anoche"],
        "en": ["Guess", "what I had for dinner"]
      },
      "explanation": {
        "es": "Pedile crear algo concreto. Adivinar datos de tu vida no es algo que pueda hacer.",
        "en": "Ask it to create something concrete. Guessing facts about your life isn't something it can do."
      }
    }
  ]
}
```

**Verificar:** `bash tools/test.sh` verde (el validador aprueba la lección).
**Commit:** `feat: lección 1 completa en ES/EN con test de validación de contenido`

### Tarea 4.3 — LessonScreen: encadenar ejercicios

Reemplazar el stub `scenes/lesson/LessonScreen.tscn` por raíz `Control` + `LessonScreen.gd`:
```gdscript
extends Control
## Corre una lección completa: HUD + ejercicios en cadena (spec §6).
## Espera Game.params = {"lesson_id": String, "review": bool}

const ESCENAS_EJERCICIO := {
	"multiple_choice": "res://scenes/exercises/MultipleChoice.tscn",
	"block_builder": "res://scenes/exercises/BlockBuilder.tscn",
}

var leccion: Dictionary
var ejercicios: Array = []
var indice := 0
var errores := 0
var perfectas := 0
var combo := 0
var es_repaso := false
var _hud: Hud
var _actual: ExerciseBase = null
var _inicio_ms := 0

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	leccion = Content.get_lesson(Game.params["lesson_id"])
	ejercicios = leccion.get("exercises", [])
	es_repaso = Game.params.get("review", false)
	_hud = load("res://scenes/ui/Hud.tscn").instantiate()
	_hud.exit_pressed.connect(_confirmar_salida)
	add_child(_hud)
	_hud.set_corazones(Economy.hearts())
	Economy.hearts_changed.connect(func(n): _hud.set_corazones(n))
	_inicio_ms = Time.get_ticks_msec()
	_mostrar_ejercicio()

func _mostrar_ejercicio() -> void:
	if _actual != null:
		_actual.queue_free()
		_actual = null
	if indice >= ejercicios.size():
		_terminar()
		return
	_hud.set_progreso(indice, ejercicios.size())
	var ej: Dictionary = ejercicios[indice]
	var esc: ExerciseBase = load(ESCENAS_EJERCICIO[ej["type"]]).instantiate()
	add_child(esc)
	move_child(esc, 1)  # debajo del HUD
	esc.setup(ej)
	esc.answered.connect(_al_responder)
	esc.continue_pressed.connect(_siguiente)
	_actual = esc

func _al_responder(correcto: bool) -> void:
	if correcto:
		perfectas += 1
		combo += 1
	else:
		errores += 1
		combo = 0
		Economy.perder_corazon()
		if Economy.hearts() <= 0:
			_sin_corazones()
			return
	_hud.set_combo(combo)

func _siguiente() -> void:
	indice += 1
	_mostrar_ejercicio()

func _terminar() -> void:
	var segundos := (Time.get_ticks_msec() - _inicio_ms) / 1000.0
	var resumen := Economy.on_lesson_finished(
		leccion["id"], perfectas, errores, segundos, es_repaso, bool(leccion.get("boss", false)))
	Game.goto("result", resumen)

func _confirmar_salida() -> void:
	var d := ConfirmationDialog.new()
	d.dialog_text = "Si salís ahora perdés el progreso de esta lección. ¿Salir?"
	d.ok_button_text = "Salir"
	d.cancel_button_text = "Seguir"
	d.confirmed.connect(func(): Game.goto("map"))
	add_child(d)
	d.popup_centered()

func _sin_corazones() -> void:
	var d := AcceptDialog.new()
	d.dialog_text = "¡Te quedaste sin corazones! Repasá una lección completada para recuperar uno."
	d.confirmed.connect(func(): Game.goto("map"))
	d.canceled.connect(func(): Game.goto("map"))
	add_child(d)
	d.popup_centered()
```

Para poder probarlo antes de que exista el mapa, cambiar **temporalmente** la pantalla inicial en `Game.gd` a `goto("lesson", {"lesson_id": "u1l01"})` (con nota `# TEMPORAL hasta Fase 6`) — la Fase 6 lo revierte. `BlockBuilder.tscn` aún no existe: hasta la Fase 5, si el tipo no está en `ESCENAS_EJERCICIO`, saltear el ejercicio con `push_warning` y `_siguiente()` — agregar ese guard en `_mostrar_ejercicio`:
```gdscript
	if not ESCENAS_EJERCICIO.has(ej["type"]) or not ResourceLoader.exists(ESCENAS_EJERCICIO[ej["type"]]):
		push_warning("Tipo de ejercicio sin escena todavía: " + str(ej["type"]))
		_siguiente()
		return
```
(El guard queda permanente: protege contra contenido con tipos futuros.)

**Verificar:** `bash tools/run.sh` → se juega la lección 1 completa (los 2 block_builder se saltean con warning), errores restan corazones, al final navega (a un ResultScreen aún stub). `bash tools/smoke.sh` y tests verdes.
**Commit:** `feat: pantalla de lección que encadena ejercicios con corazones y combo`

### Tarea 4.4 — ResultScreen

Reemplazar stub `scenes/ui/ResultScreen.tscn` por raíz `Control` + `ResultScreen.gd`:
```gdscript
extends Control
## Muestra el resumen que dejó Economy.on_lesson_finished en Game.params:
## {"xp": int, "estrellas": int, "racha": int, "sumo_racha": bool}

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	var r: Dictionary = Game.params
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.custom_minimum_size = Vector2(560, 0)
	caja.add_theme_constant_override("separation", 24)
	caja.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(caja)

	var titulo := UiTheme.etiqueta("¡Lección completada!", 36, UiTheme.PRIMARIO)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(titulo)

	var fila_estrellas := HBoxContainer.new()
	fila_estrellas.alignment = BoxContainer.ALIGNMENT_CENTER
	for k in 3:
		fila_estrellas.add_child(Icono.nuevo("estrella", k < int(r.get("estrellas", 1)), 72.0))
	caja.add_child(fila_estrellas)

	var lbl_xp := UiTheme.etiqueta("+0 XP", 32, UiTheme.DORADO)
	lbl_xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(lbl_xp)
	var tween := create_tween()
	tween.tween_method(func(v: int): lbl_xp.text = "+%d XP" % v, 0, int(r.get("xp", 0)), 0.8)

	if r.get("sumo_racha", false):
		var fila_racha := HBoxContainer.new()
		fila_racha.alignment = BoxContainer.ALIGNMENT_CENTER
		fila_racha.add_child(Icono.nuevo("fuego", true, 36.0))
		fila_racha.add_child(UiTheme.etiqueta("¡Racha de %d días!" % int(r.get("racha", 1)), 26))
		caja.add_child(fila_racha)

	var btn := UiTheme.boton("CONTINUAR")
	btn.pressed.connect(func(): Game.goto("map"))
	caja.add_child(btn)
```

**Verificar:** `bash tools/run.sh` → terminar la lección muestra XP animado, estrellas y racha; CONTINUAR navega al mapa (stub). Tests + smoke verdes.
**Commit:** `feat: pantalla de resultado con XP animado y estrellas`

---

## Fase 5 — Ejercicio de armar prompt con bloques

### Tarea 5.1 — BlockLogic (lógica pura, TDD)

**Test primero** — `tests/test_block_logic.gd`:
```gdscript
extends TestCase

func test_pool_mezclado_contiene_todo() -> void:
	var pool := BlockLogic.armar_pool(["a", "b", "c"], ["x", "y"], 1234)
	check_eq(pool.size(), 5, "solución + distractores")
	for bloque in ["a", "b", "c", "x", "y"]:
		check(pool.has(bloque), "falta el bloque " + bloque)

func test_pool_es_deterministico_con_semilla() -> void:
	var p1 := BlockLogic.armar_pool(["a", "b", "c"], ["x"], 42)
	var p2 := BlockLogic.armar_pool(["a", "b", "c"], ["x"], 42)
	check_eq(p1, p2, "misma semilla, mismo orden")

func test_verificacion_orden_exacto() -> void:
	var sol := ["Escribí", "una receta", "de pizza."]
	check_eq(BlockLogic.es_correcta(["Escribí", "una receta", "de pizza."], sol), true, "orden exacto")
	check_eq(BlockLogic.es_correcta(["una receta", "Escribí", "de pizza."], sol), false, "orden cambiado")
	check_eq(BlockLogic.es_correcta(["Escribí", "una receta"], sol), false, "incompleta")
	check_eq(BlockLogic.es_correcta(["Escribí", "una receta", "de pizza.", "extra"], sol), false, "de más")
```

Correr → FALLA. **Implementación** — `scripts/block_logic.gd`:
```gdscript
class_name BlockLogic
## Lógica pura del ejercicio de bloques (spec §5.4): mezcla y verificación.

static func armar_pool(solucion: Array, distractores: Array, semilla: int) -> Array:
	var pool := solucion.duplicate()
	pool.append_array(distractores)
	var rng := RandomNumberGenerator.new()
	rng.seed = semilla
	# Fisher-Yates con rng propio para que los tests sean deterministas.
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	return pool

static func es_correcta(seleccion: Array, solucion: Array) -> bool:
	return seleccion == solucion
```

**Verificar:** tests OK. **Commit:** `feat: lógica de bloques con mezcla determinista y tests`

### Tarea 5.2 — BlockBuilder (UI tap-to-place)

Decisión de diseño: **tocar para colocar** en vez de drag & drop (más simple y más usable en pantallas chicas; es lo que hace el propio Duolingo). Tocás un bloque del pool → va a tu respuesta; tocás un bloque de tu respuesta → vuelve al pool.

`scenes/exercises/BlockBuilder.gd` (con `BlockBuilder.tscn` mínimo, raíz `Control` + script):
```gdscript
extends ExerciseBase
## data: {goal: String, solution: Array[String], distractors: Array[String], explanation: String}

var _respuesta: Array = []
var _fila_respuesta: HFlowContainer
var _pool_cont: HFlowContainer
var _btn_verificar: Button

func _build() -> void:
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_FULL_RECT)
	caja.offset_left = 24
	caja.offset_right = -24
	caja.offset_top = 130
	caja.add_theme_constant_override("separation", 20)
	add_child(caja)
	caja.add_child(UiTheme.etiqueta(str(data["goal"]), 28))

	var zona := UiTheme.panel(Color("0d0d22"))
	zona.custom_minimum_size = Vector2(0, 140)
	caja.add_child(zona)
	_fila_respuesta = HFlowContainer.new()
	_fila_respuesta.add_theme_constant_override("h_separation", 10)
	zona.add_child(_fila_respuesta)

	_pool_cont = HFlowContainer.new()
	_pool_cont.add_theme_constant_override("h_separation", 10)
	caja.add_child(_pool_cont)

	var pool := BlockLogic.armar_pool(data["solution"], data.get("distractors", []),
		hash(str(data["goal"])))  # semilla estable por ejercicio
	for bloque in pool:
		_pool_cont.add_child(_hacer_bloque(str(bloque), true))

	_btn_verificar = UiTheme.boton("VERIFICAR", UiTheme.ACENTO)
	_btn_verificar.disabled = true
	_btn_verificar.pressed.connect(_verificar)
	caja.add_child(_btn_verificar)

func _hacer_bloque(texto: String, en_pool: bool) -> Button:
	var b := UiTheme.boton(texto, UiTheme.PANEL if en_pool else UiTheme.ACENTO)
	b.add_theme_font_size_override("font_size", 22)
	b.custom_minimum_size = Vector2(0, 52)
	b.pressed.connect(func(): _mover(b, en_pool))
	return b

func _mover(b: Button, estaba_en_pool: bool) -> void:
	if _respondido:
		return
	var texto := b.text
	b.queue_free()
	if estaba_en_pool:
		_respuesta.append(texto)
		_fila_respuesta.add_child(_hacer_bloque(texto, false))
	else:
		_respuesta.erase(texto)
		_pool_cont.add_child(_hacer_bloque(texto, true))
	_btn_verificar.disabled = _respuesta.is_empty()

func _verificar() -> void:
	_btn_verificar.disabled = true
	_responder(BlockLogic.es_correcta(_respuesta, data["solution"]))
```

Nota: `_respuesta.erase(texto)` borra la primera aparición — correcto incluso si dos bloques tuvieran el mismo texto.

**Verificar:** `bash tools/run.sh` → en la lección 1 los dos ejercicios de bloques ya se juegan: armar bien acepta, armar mal resta corazón y muestra la solución en la explicación. Tests + smoke verdes.
**Commit:** `feat: ejercicio de armar prompt con bloques (tap-to-place)`

---

## Fase 6 — Mapa de niveles

### Tarea 6.1 — ProgressLogic (TDD) + LessonNode + MapScreen

**Test primero** — `tests/test_progress_logic.gd`:
```gdscript
extends TestCase

const IDS := ["u1l01", "u1l02", "u1l03"]

func test_estados_iniciales() -> void:
	check_eq(ProgressLogic.estado("u1l01", IDS, {}), "actual", "la primera arranca jugable")
	check_eq(ProgressLogic.estado("u1l02", IDS, {}), "bloqueada", "la segunda arranca bloqueada")

func test_completar_desbloquea_la_siguiente() -> void:
	var avance := {"u1l01": {"stars": 2}}
	check_eq(ProgressLogic.estado("u1l01", IDS, avance), "completada", "con estrellas queda completada")
	check_eq(ProgressLogic.estado("u1l02", IDS, avance), "actual", "se desbloquea la siguiente")
	check_eq(ProgressLogic.estado("u1l03", IDS, avance), "bloqueada", "la tercera sigue bloqueada")
```

Correr → FALLA. **Implementación** — `scripts/progress_logic.gd`:
```gdscript
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
```

**Implementación UI** — `scenes/map/LessonNode.gd` (+ `LessonNode.tscn` mínimo, raíz `VBoxContainer` + script):
```gdscript
extends VBoxContainer
class_name LessonNode
## Nodo del mapa: botón circular + título + estrellas.

signal pressed(id: String)

func configurar(meta: Dictionary, estado: String, estrellas: int) -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	var b := Button.new()
	b.custom_minimum_size = Vector2(110, 110)
	b.text = "👑" if meta.get("boss", false) else ""
	var color := {"completada": UiTheme.DORADO, "actual": UiTheme.PRIMARIO,
		"bloqueada": Color("2a2a4e")}[estado]
	var st := StyleBoxFlat.new()
	st.bg_color = color
	st.set_corner_radius_all(55)
	for modo in ["normal", "hover", "pressed", "disabled"]:
		b.add_theme_stylebox_override(modo, st)
	b.disabled = estado == "bloqueada"
	if estado == "actual":
		# pulso para señalar la lección jugable
		var t := create_tween().set_loops()
		t.tween_property(b, "scale", Vector2(1.08, 1.08), 0.5).set_trans(Tween.TRANS_SINE)
		t.tween_property(b, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_SINE)
		b.pivot_offset = Vector2(55, 55)
	b.pressed.connect(func(): pressed.emit(meta["id"]))
	add_child(b)

	var titulo := UiTheme.etiqueta(str(meta["title"]), 18,
		UiTheme.TEXTO if estado != "bloqueada" else UiTheme.TEXTO_SUAVE)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.custom_minimum_size = Vector2(220, 0)
	add_child(titulo)

	if estado == "completada":
		var fila := HBoxContainer.new()
		fila.alignment = BoxContainer.ALIGNMENT_CENTER
		for k in 3:
			fila.add_child(Icono.nuevo("estrella", k < estrellas, 22.0))
		add_child(fila)
```
(Si `👑` no renderiza con la fuente por defecto, reemplazar por el texto `"BOSS"` — decisión al probar en 9.1.)

`scenes/map/MapScreen.gd` (reemplaza el stub, raíz `Control` + script):
```gdscript
extends Control
## Mapa: HUD superior + camino vertical de lecciones (spec §6).

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	_armar_hud_superior()
	_armar_camino()

func _armar_hud_superior() -> void:
	var fila := HBoxContainer.new()
	fila.set_anchors_preset(Control.PRESET_TOP_WIDE)
	fila.offset_left = 20
	fila.offset_right = -20
	fila.offset_top = 14
	fila.add_theme_constant_override("separation", 18)
	add_child(fila)
	fila.add_child(Icono.nuevo("fuego", Economy.racha() > 0))
	fila.add_child(UiTheme.etiqueta(str(Economy.racha()), 24))
	fila.add_child(Icono.nuevo("corazon", Economy.hearts() > 0))
	fila.add_child(UiTheme.etiqueta(str(Economy.hearts()), 24))
	var espacio := Control.new()
	espacio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fila.add_child(espacio)
	fila.add_child(UiTheme.etiqueta("XP %d" % Economy.xp_total(), 24, UiTheme.DORADO))

func _armar_camino() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_top = 70
	add_child(scroll)
	var caja := VBoxContainer.new()
	caja.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caja.add_theme_constant_override("separation", 34)
	scroll.add_child(caja)
	var avance: Dictionary = SaveData.get_value("lessons", {})
	var ids: Array = Content.UNIT1_IDS
	var i := 0
	for meta in Content.get_unit_lessons():
		# Cada nodo va en una fila con "aire" desigual a los costados → camino en zigzag.
		# (No usar position.x: los contenedores la pisan al ordenar a sus hijos.)
		var fila_nodo := HBoxContainer.new()
		fila_nodo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		caja.add_child(fila_nodo)
		var izq := Control.new()
		izq.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		izq.size_flags_stretch_ratio = [1.0, 2.2, 0.5][i % 3]
		fila_nodo.add_child(izq)
		var nodo: LessonNode = load("res://scenes/map/LessonNode.tscn").instantiate()
		fila_nodo.add_child(nodo)
		var der := Control.new()
		der.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		der.size_flags_stretch_ratio = [1.0, 0.5, 2.2][i % 3]
		fila_nodo.add_child(der)
		var estado := ProgressLogic.estado(meta["id"], ids, avance)
		nodo.configurar(meta, estado, int(avance.get(meta["id"], {}).get("stars", 0)))
		nodo.pressed.connect(_al_tocar)
		i += 1

func _al_tocar(id: String) -> void:
	var avance: Dictionary = SaveData.get_value("lessons", {})
	var estado := ProgressLogic.estado(id, Content.UNIT1_IDS, avance)
	if estado == "completada":
		var d := ConfirmationDialog.new()
		d.dialog_text = "Ya completaste esta lección. ¿Repasarla? (recuperás 1 corazón)"
		d.ok_button_text = "Repasar"
		d.confirmed.connect(func(): Game.goto("lesson", {"lesson_id": id, "review": true}))
		add_child(d)
		d.popup_centered()
		return
	if not Economy.can_start_lesson():
		var d2 := AcceptDialog.new()
		d2.dialog_text = "Sin corazones. Esperá que se regeneren o repasá una lección completada."
		add_child(d2)
		d2.popup_centered()
		return
	Game.goto("lesson", {"lesson_id": id, "review": false})
```

Además: **revertir el arranque temporal** de `Game.gd` (volver a `"intro"/"map"` según `intro_seen`).

**Verificar:** `bash tools/run.sh` → mapa con 1 nodo jugable (solo existe lesson_01), jugarla la completa y muestra estrellas en el nodo; nodos futuros aparecen a medida que existan los JSON. Tests + smoke verdes.
**Commit:** `feat: mapa de niveles con desbloqueo lineal, repaso y HUD superior`

---

## Fase 7 — Byte, intro, ajustes e i18n de UI

### Tarea 7.1 — I18n propio (TDD) — reemplaza textos hardcodeados

Decisión (ver Tarea 3.2): i18n propio en vez del sistema de Translation de Godot, para no depender de la importación del editor en headless.

**Test primero** — `tests/test_i18n.gd`:
```gdscript
extends TestCase

func test_traduce_y_hace_fallback() -> void:
	I18n.idioma_actual = "en"
	check_eq(I18n.t("CONTINUAR"), "CONTINUE", "clave en inglés")
	I18n.idioma_actual = "es"
	check_eq(I18n.t("CONTINUAR"), "CONTINUAR", "clave en español")
	check_eq(I18n.t("NO_EXISTE"), "NO_EXISTE", "clave desconocida devuelve la clave")
```

Correr → FALLA. **Implementación** — `scripts/i18n.gd`:
```gdscript
class_name I18n
## Traducciones de UI. El contenido de lecciones NO pasa por acá (ya es bilingüe en JSON).

static var idioma_actual := "es"

const DIC := {
	"CONTINUAR": {"es": "CONTINUAR", "en": "CONTINUE"},
	"VERIFICAR": {"es": "VERIFICAR", "en": "CHECK"},
	"CORRECTO": {"es": "¡Correcto!", "en": "Correct!"},
	"INCORRECTO": {"es": "Ups, no era así", "en": "Oops, not quite"},
	"COMBO": {"es": "¡Combo x%d!", "en": "Combo x%d!"},
	"SALIR_CONFIRMA": {"es": "Si salís ahora perdés el progreso de esta lección. ¿Salir?", "en": "If you leave now you lose this lesson's progress. Leave?"},
	"SALIR": {"es": "Salir", "en": "Leave"},
	"SEGUIR": {"es": "Seguir", "en": "Keep going"},
	"SIN_CORAZONES": {"es": "¡Te quedaste sin corazones! Repasá una lección para recuperar uno.", "en": "You ran out of hearts! Review a lesson to recover one."},
	"SIN_CORAZONES_MAPA": {"es": "Sin corazones. Esperá que se regeneren o repasá una lección completada.", "en": "No hearts. Wait for them to regenerate or review a completed lesson."},
	"REPASAR_PREGUNTA": {"es": "Ya completaste esta lección. ¿Repasarla? (recuperás 1 corazón)", "en": "You already completed this lesson. Review it? (recover 1 heart)"},
	"REPASAR": {"es": "Repasar", "en": "Review"},
	"LECCION_COMPLETADA": {"es": "¡Lección completada!", "en": "Lesson complete!"},
	"RACHA_DIAS": {"es": "¡Racha de %d días!", "en": "%d day streak!"},
	"UNIDAD_COMPLETADA": {"es": "¡Venciste al Boss! Unidad completada", "en": "You beat the Boss! Unit complete"},
	"BOSS_FALLADO": {"es": "El Boss te ganó esta vez (necesitás 9 de 12). ¡Reintentá!", "en": "The Boss won this time (you need 9 of 12). Try again!"},
	"INTRO_1": {"es": "En el Mundo Digital, una pequeña IA acaba de despertar...", "en": "In the Digital World, a little AI just woke up..."},
	"INTRO_2": {"es": "\"¡Hola! Soy Byte. Perdí mis fragmentos de memoria y no recuerdo cómo funciono.\"", "en": "\"Hi! I'm Byte. I lost my memory fragments and can't remember how I work.\""},
	"INTRO_3": {"es": "Ayudá a Byte a recuperarlos: cada lección que completes le devuelve un fragmento. ¡Y de paso te volvés experto en IA!", "en": "Help Byte recover them: every lesson you complete returns one fragment. And you become an AI expert along the way!"},
	"EMPEZAR": {"es": "¡EMPEZAR!", "en": "START!"},
	"SALTAR": {"es": "Saltar", "en": "Skip"},
	"AJUSTES": {"es": "Ajustes", "en": "Settings"},
	"IDIOMA": {"es": "Idioma", "en": "Language"},
	"SONIDO": {"es": "Sonido", "en": "Sound"},
	"CERRAR": {"es": "Cerrar", "en": "Close"},
}

static func t(clave: String) -> String:
	return DIC.get(clave, {}).get(idioma_actual, clave) if DIC.has(clave) else clave
```

Cablear: en `Content.set_idioma()` y en `Game._ready()` agregar `I18n.idioma_actual = <idioma>`. Reemplazar TODOS los literales de UI ya escritos (buscar con grep los strings en español de Hud, ExerciseBase, LessonScreen, ResultScreen, MapScreen) por `I18n.t("CLAVE")` según la tabla de arriba. El `tr("COMBO_MSG")` del Hud pasa a `I18n.t("COMBO")`.

**Verificar:** tests verdes; `bash tools/run.sh` y cambiar a mano `"language": "en"` en el save → toda la UI y el contenido salen en inglés.
**Commit:** `feat: i18n propio de UI en ES/EN`

### Tarea 7.2 — Mascota Byte + reacciones en lección y resultado

`scenes/mascot/Mascot.gd` (+ `Mascot.tscn` mínimo, raíz `Control` + script):
```gdscript
extends Control
class_name Mascot
## Byte: robot simple dibujado a mano. animo: "neutral"|"feliz"|"triste"|"festejo"

var animo := "neutral"

func set_animo(a: String) -> void:
	animo = a
	queue_redraw()
	pivot_offset = size / 2.0
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.15, 1.15), 0.12)
	t.tween_property(self, "scale", Vector2.ONE, 0.18)

func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size / 2.0
	# antena
	draw_line(c + Vector2(0, -s * 0.38), c + Vector2(0, -s * 0.5), UiTheme.ACENTO, s * 0.03)
	draw_circle(c + Vector2(0, -s * 0.52), s * 0.05, UiTheme.DORADO if animo == "festejo" else UiTheme.ACENTO)
	# cuerpo
	draw_circle(c, s * 0.38, UiTheme.ACENTO)
	draw_circle(c, s * 0.33, Color("0e2f4a"))
	# ojos según ánimo
	var oy := -s * 0.06
	if animo == "triste":
		oy = -s * 0.02
	var col_ojo := UiTheme.DORADO if animo == "festejo" else Color("9fe8ff")
	if animo == "feliz" or animo == "festejo":
		# ojos como arcos felices (dos rectángulos finos inclinados)
		draw_rect(Rect2(c + Vector2(-s * 0.18, oy), Vector2(s * 0.1, s * 0.035)), col_ojo)
		draw_rect(Rect2(c + Vector2(s * 0.08, oy), Vector2(s * 0.1, s * 0.035)), col_ojo)
	else:
		draw_circle(c + Vector2(-s * 0.12, oy), s * 0.05, col_ojo)
		draw_circle(c + Vector2(s * 0.12, oy), s * 0.05, col_ojo)
	# boca
	match animo:
		"feliz", "festejo":
			draw_rect(Rect2(c + Vector2(-s * 0.1, s * 0.1), Vector2(s * 0.2, s * 0.05)), col_ojo)
		"triste":
			draw_rect(Rect2(c + Vector2(-s * 0.08, s * 0.14), Vector2(s * 0.16, s * 0.03)), Color("6080a0"))
		_:
			draw_rect(Rect2(c + Vector2(-s * 0.06, s * 0.12), Vector2(s * 0.12, s * 0.03)), col_ojo)
```

Integraciones:
1. **LessonScreen:** instanciar `Mascot` (100×100, esquina inferior izquierda, `set_anchors_preset(PRESET_BOTTOM_LEFT)` con offsets). En `_al_responder`: `_byte.set_animo("feliz" if correcto else "triste")`. Al inicio de la lección, mostrar `byte_intro` en un panel con el Byte y botón CONTINUAR antes del primer ejercicio (un overlay simple con `UiTheme.panel`; al tocarlo se libera y llama `_mostrar_ejercicio()`).
2. **LessonScreen `_terminar`:** agregar `resumen["byte_outro"] = leccion.get("byte_outro", "")` antes de `Game.goto`.
3. **ResultScreen:** agregar arriba del título un `Mascot` 140×140 con `set_animo("festejo")` y, si `byte_outro` no está vacío, una etiqueta con ese texto (20, TEXTO_SUAVE, centrada).

**Verificar:** `bash tools/run.sh` → Byte saluda al inicio, reacciona a aciertos/errores y festeja en el resultado. Smoke + tests verdes.
**Commit:** `feat: mascota Byte con expresiones y micro-diálogos`

### Tarea 7.3 — IntroScreen + SettingsPanel

`scenes/intro/IntroScreen.gd` (reemplaza stub, raíz `Control` + script):
```gdscript
extends Control
## 3 pantallas de historia, solo la primera vez (spec §3). Saltable.

var pagina := 0
var _lbl: Label
var _btn: Button

func _ready() -> void:
	UiTheme.fondo_pantalla(self)
	var caja := VBoxContainer.new()
	caja.set_anchors_preset(Control.PRESET_CENTER)
	caja.custom_minimum_size = Vector2(560, 0)
	caja.add_theme_constant_override("separation", 30)
	add_child(caja)
	var byte := Mascot.new()
	byte.custom_minimum_size = Vector2(180, 180)
	byte.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	caja.add_child(byte)
	_lbl = UiTheme.etiqueta(I18n.t("INTRO_1"), 26)
	_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caja.add_child(_lbl)
	_btn = UiTheme.boton(I18n.t("CONTINUAR"))
	_btn.pressed.connect(_avanzar)
	caja.add_child(_btn)
	var saltar := UiTheme.boton(I18n.t("SALTAR"), UiTheme.PANEL)
	saltar.pressed.connect(_terminar)
	caja.add_child(saltar)

func _avanzar() -> void:
	pagina += 1
	if pagina >= 3:
		_terminar()
		return
	_lbl.text = I18n.t("INTRO_%d" % (pagina + 1))
	if pagina == 2:
		_btn.text = I18n.t("EMPEZAR")

func _terminar() -> void:
	SaveData.set_value("intro_seen", true)
	Game.goto("map")
```

`scenes/ui/SettingsPanel.gd` (+ `SettingsPanel.tscn` mínimo, raíz `Control` + script) — overlay que abre el mapa:
```gdscript
extends Control
class_name SettingsPanel

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var velo := ColorRect.new()
	velo.color = Color(0, 0, 0, 0.6)
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(velo)
	var panel := UiTheme.panel()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(480, 0)
	add_child(panel)
	var caja := VBoxContainer.new()
	caja.add_theme_constant_override("separation", 20)
	panel.add_child(caja)
	caja.add_child(UiTheme.etiqueta(I18n.t("AJUSTES"), 30))

	var fila_idioma := HBoxContainer.new()
	fila_idioma.add_child(UiTheme.etiqueta(I18n.t("IDIOMA"), 24))
	var sel := OptionButton.new()
	sel.add_item("Español")   # index 0 → "es"
	sel.add_item("English")   # index 1 → "en"
	sel.selected = 0 if Content.idioma() == "es" else 1
	sel.item_selected.connect(func(i: int):
		Content.set_idioma("es" if i == 0 else "en")
		Game.goto("map"))  # reconstruye el mapa en el idioma nuevo
	fila_idioma.add_child(sel)
	caja.add_child(fila_idioma)

	var fila_sonido := HBoxContainer.new()
	fila_sonido.add_child(UiTheme.etiqueta(I18n.t("SONIDO"), 24))
	var chk := CheckButton.new()
	var ajustes: Dictionary = SaveData.get_value("settings", {"sound": true})
	chk.button_pressed = ajustes.get("sound", true)
	chk.toggled.connect(func(on: bool):
		ajustes["sound"] = on
		SaveData.set_value("settings", ajustes))
	fila_sonido.add_child(chk)
	caja.add_child(fila_sonido)

	var cerrar := UiTheme.boton(I18n.t("CERRAR"), UiTheme.PANEL)
	cerrar.pressed.connect(queue_free)
	caja.add_child(cerrar)
```

En `MapScreen._armar_hud_superior()` agregar al final un botón `⚙` (flat, font 28) que hace `add_child(load("res://scenes/ui/SettingsPanel.tscn").instantiate())`. En `Content.set_idioma` ya queda cableado `I18n.idioma_actual` (Tarea 7.1).

**Verificar:** `bash tools/run.sh` con save borrado → intro completa → mapa; cambiar idioma en ⚙ reconstruye todo en inglés; sonido queda persistido. Smoke + tests verdes.
**Commit:** `feat: intro narrativa y panel de ajustes con idioma en vivo`

---

## Fase 8 — Contenido: lecciones 2 a 9

Reglas comunes a las 4 tareas: cada lección sigue EXACTAMENTE el formato de `lesson_01.json` (Tarea 4.2). 8 ejercicios por lección; lecciones 2–5 (conceptuales): 6 opción múltiple + 2 bloques; lecciones 6–9 (de práctica de prompts): 5 opción múltiple + 3 bloques. Todo campo de texto con `es` y `en`. `byte_intro`/`byte_outro` propios de cada tema. Los datos técnicos se escriben con precisión (spec §8: ante la duda, simplificar antes que afirmar algo incorrecto). **Verificación de cada tarea:** `bash tools/test.sh` (el validador de la Tarea 4.2 cubre los archivos nuevos automáticamente) + jugar una de las lecciones nuevas con `bash tools/run.sh`.

### Tarea 8.1 — Lecciones 2 y 3
- **lesson_02.json — "¿Qué es un LLM?"**: LLM = modelo grande de lenguaje; se entrena UNA vez con muchísimo texto y después se usa (entrenar ≠ chatear); no navega por internet por sí solo salvo que le den herramientas; su conocimiento tiene fecha de corte. Ej. de pregunta: "¿Por qué un LLM puede no conocer una noticia de ayer?" / bloques: armar "Un LLM aprende de / texto de entrenamiento / no de tus chats privados."
- **lesson_03.json — "Tokens y contexto"**: los modelos leen tokens (pedacitos de palabras), no letras; la ventana de contexto es su memoria de trabajo limitada; si la conversación es muy larga, lo del principio puede quedar afuera; conviene dar la info importante junta y clara. Ej.: "¿Qué pasa si tu conversación supera la ventana de contexto?" / bloques: "El contexto es / la memoria de trabajo / de la conversación."

**Commit:** `content: lecciones 2 y 3 (LLM, tokens y contexto) en ES/EN`

### Tarea 8.2 — Lecciones 4 y 5
- **lesson_04.json — "Cómo 'piensa'"**: genera prediciendo la continuación más probable, palabra a palabra; no "consulta una base de datos de respuestas"; por eso redacta fluido incluso cuando se equivoca; pedirle que razone paso a paso mejora resultados en problemas complejos. Ej.: "¿Por qué una respuesta incorrecta puede sonar convincente?"
- **lesson_05.json — "Alucinaciones"**: alucinación = inventar datos con total seguridad (fuentes, cifras, nombres); pasa más en datos específicos y verificables; hábito: verificar todo dato importante en una fuente real; pedir "si no lo sabés, decilo" ayuda pero no es garantía. Ej.: bloques: "Antes de usar un dato de la IA / lo verifico / en una fuente confiable."

**Commit:** `content: lecciones 4 y 5 (predicción y alucinaciones) en ES/EN`

### Tarea 8.3 — Lecciones 6 y 7
- **lesson_06.json — "Tu primer prompt"**: específico > vago (tema, cantidad, tono, audiencia); comparar prompts malos vs buenos; un pedido por vez. Ej. MC: elegir el prompt más claro entre 3; bloques: armar un prompt específico completo.
- **lesson_07.json — "Contexto y rol"**: dar contexto relevante ("soy principiante", "es para un mail de trabajo"); asignar rol ("actuá como profesor de historia"); el rol orienta tono y nivel de detalle. Ej.: bloques: "Actuá como / un entrenador personal / y armame una rutina de 20 minutos."

**Commit:** `content: lecciones 6 y 7 (prompts claros, contexto y rol) en ES/EN`

### Tarea 8.4 — Lecciones 8 y 9
- **lesson_08.json — "Formato de salida"**: pedir la forma exacta (lista, tabla, pasos numerados, máximo de palabras); ejemplos de instrucciones de formato; comparar salida libre vs formateada. Ej.: bloques: "Respondé / en una tabla / de 3 columnas."
- **lesson_09.json — "Enseñar con ejemplos"**: few-shot = mostrar 1–2 ejemplos del resultado esperado; útil para formatos y estilos difíciles de describir; el modelo imita el patrón. Ej. MC: "¿Cuándo conviene dar ejemplos en el prompt?"

**Commit:** `content: lecciones 8 y 9 (formato y few-shot) en ES/EN`

---

## Fase 9 — Boss del Núcleo

### Tarea 9.1 — Modo boss: timer + regla de aprobación + lesson_10.json

**Contenido** — `content/unit1/lesson_10.json`: mismo formato + `"boss": true` al nivel raíz. **12 ejercicios** (7 opción múltiple + 5 bloques) que repasan las lecciones 1–9 SIN repetir enunciados textuales: 1 de qué es IA generativa, 1 de LLM/entrenamiento, 2 de tokens/contexto, 1 de predicción, 2 de alucinaciones/verificación, 2 de prompts claros, 1 de rol, 1 de formato, 1 de few-shot. `title`: `{"es": "Boss del Núcleo", "en": "Core Boss"}`.

**Código:**
1. `Hud.gd` — agregar cuenta regresiva:
```gdscript
var _lbl_tiempo: Label
# en _ready(), después de _lbl_combo:
	_lbl_tiempo = UiTheme.etiqueta("", 24, UiTheme.PELIGRO)
	_lbl_tiempo.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_lbl_tiempo.position = Vector2(size.x - 90, 72)
	add_child(_lbl_tiempo)

func set_tiempo(seg: int) -> void:
	_lbl_tiempo.text = ("%ds" % seg) if seg >= 0 else ""
```
2. `ExerciseBase.gd` — agregar:
```gdscript
func bloquear() -> void:
	## El tiempo se agotó: el ejercicio deja de aceptar respuestas.
	_respondido = true
```
3. `LessonScreen.gd` — agregar:
```gdscript
const BOSS_SEGUNDOS := 20
var es_boss := false
var _timer: Timer

# en _ready(), tras cargar leccion:
	es_boss = bool(leccion.get("boss", false))
	if es_boss:
		_timer = Timer.new()
		_timer.one_shot = true
		_timer.timeout.connect(_tiempo_agotado)
		add_child(_timer)

# en _mostrar_ejercicio(), después de esc.setup(ej):
	if es_boss:
		_timer.start(BOSS_SEGUNDOS)

# en _al_responder(), primera línea:
	if es_boss:
		_timer.stop()

func _process(_delta: float) -> void:
	if es_boss and _timer != null and not _timer.is_stopped():
		_hud.set_tiempo(int(ceil(_timer.time_left)))

func _tiempo_agotado() -> void:
	if _actual != null:
		_actual.bloquear()
	errores += 1
	combo = 0
	_hud.set_combo(0)
	_hud.set_tiempo(-1)
	Economy.perder_corazon()
	if Economy.hearts() <= 0:
		_sin_corazones()
		return
	_siguiente()

# _terminar() pasa a ser:
func _terminar() -> void:
	var segundos := (Time.get_ticks_msec() - _inicio_ms) / 1000.0
	if es_boss and errores > 3:  # aprobar = ≥9/12 correctas (spec §2.4)
		var d := AcceptDialog.new()
		d.dialog_text = I18n.t("BOSS_FALLADO")
		d.confirmed.connect(func(): Game.goto("map"))
		d.canceled.connect(func(): Game.goto("map"))
		add_child(d)
		d.popup_centered()
		return
	var resumen := Economy.on_lesson_finished(
		leccion["id"], perfectas, errores, segundos, es_repaso, es_boss)
	resumen["byte_outro"] = leccion.get("byte_outro", "")
	resumen["boss"] = es_boss
	Game.goto("result", resumen)
```
4. `ResultScreen.gd` — el título pasa a: `I18n.t("UNIDAD_COMPLETADA") if Game.params.get("boss", false) else I18n.t("LECCION_COMPLETADA")`.

**Verificar:** tests verdes (validador cubre lesson_10); `bash tools/run.sh` → jugar el boss: el timer corre y descuenta al agotarse, con 4+ errores no aprueba y con ≤3 muestra "¡Unidad completada!" y XP base 20.
**Commit:** `feat: boss cronometrado con regla de aprobación 9/12`

---

## Fase 10 — Sonido

### Tarea 10.1 — SFX generados por código

`autoload/Audio.gd` (registrar en `[autoload]` de project.godot, después de Game):
```gdscript
extends Node
## Autoload. Efectos de sonido sintetizados: cero assets binarios.

var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)

func _activo() -> bool:
	return SaveData.get_value("settings", {"sound": true}).get("sound", true)

func acierto() -> void: _tocar([880.0])
func error() -> void: _tocar([196.0])
func festejo() -> void: _tocar([523.25, 659.25, 783.99, 1046.5])

func _tocar(frecuencias: Array) -> void:
	if not _activo():
		return
	_player.stream = _melodia(frecuencias)
	_player.play()

func _melodia(frecuencias: Array, dur := 0.12) -> AudioStreamWAV:
	var hz := 22050
	var n_nota := int(dur * hz)
	var bytes := PackedByteArray()
	bytes.resize(n_nota * frecuencias.size() * 2)
	var idx := 0
	for f in frecuencias:
		for i in n_nota:
			var envolvente := 1.0 - float(i) / n_nota  # fade out por nota
			var v := int(sin(TAU * f * i / hz) * 32767.0 * 0.35 * envolvente)
			bytes.encode_s16(idx * 2, v)
			idx += 1
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = hz
	wav.data = bytes
	return wav
```
Cablear: en `ExerciseBase._responder()` → `Audio.acierto()` / `Audio.error()` según `correcto`; en `ResultScreen._ready()` → `Audio.festejo()`.

**Verificar:** `bash tools/run.sh` → suenan acierto/error/festejo; apagar sonido en ⚙ los silencia. Smoke + tests verdes.
**Commit:** `feat: efectos de sonido sintetizados con toggle en ajustes`

---

## Fase 11 — Ícono, export Android y cierre

### Tarea 11.1 — Ícono generado + configuración

`tools/gen_icon.gd`:
```gdscript
extends SceneTree
## Genera assets/icon.png (512x512, cara de Byte). Correr: bash tools/gen_icon.sh

func _initialize() -> void:
	var img := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	for y in 512:
		for x in 512:
			var d := Vector2(x - 256, y - 256).length()
			var col := Color("12122b")
			if d < 205.0: col = Color("1cb0f6")
			if d < 172.0: col = Color("0e2f4a")
			if Vector2(x - 195, y - 230).length() < 27.0: col = Color("9fe8ff")
			if Vector2(x - 317, y - 230).length() < 27.0: col = Color("9fe8ff")
			if absi(y - 325) < 13 and absi(x - 256) < 52: col = Color("9fe8ff")
			img.set_pixel(x, y, col)
	img.save_png("res://assets/icon.png")
	print("icono generado")
	quit(0)
```
`tools/gen_icon.sh` (igual a test.sh pero con `-s res://tools/gen_icon.gd`). Correrlo, y en `project.godot` `[application]` agregar `config/icon="res://assets/icon.png"`.

**Verificar:** existe `assets/icon.png` y se ve la cara de Byte; smoke OK.
**Commit:** `feat: ícono de la app generado por código`

### Tarea 11.2 — Preset de export Android + guía de publicación

⚠️ **Requiere pasos manuales del usuario** (instalar Android SDK + JDK 17 y crear keystore): esta tarea deja todo documentado y el preset versionado; el `.aab` final se genera cuando el entorno Android esté listo.

1. Crear `export/.gitkeep`. Abrir UNA vez el editor (`bash tools/run.sh` pero con el editor: `"$GODOT_EXE" -e --path .`) → Proyecto → Exportar → añadir preset **Android** → cerrar. Esto genera `export_presets.cfg` con las claves canónicas de 4.6.3. Editarlo: `package/unique_name="org.promptquest.game"`, `package/name="PromptQuest"`, `version/code=1`, `version/name="0.1.0"`, formato **AAB** para release.
2. Escribir `docs/publicacion-play-store.md` con la checklist de la spec §7 (los 8 puntos, cada uno con su acción concreta) + los pasos de entorno: instalar Android Studio (SDK) y JDK 17, configurarlos en Editor Settings → Export → Android, `keytool -genkeypair -v -keystore promptquest.keystore -alias promptquest -keyalg RSA -keysize 2048 -validity 10000` y respaldo del keystore FUERA del repo (está en .gitignore).
3. Los export templates 4.6.3 ya están instalados en esta máquina (verificado): anotarlo en la guía.

**Verificar:** `export_presets.cfg` existe y está commiteado; la guía cubre los 8 puntos de la spec §7. Si el SDK ya estuviera configurado: `"$GODOT_EXE" --headless --path . --export-debug Android export/promptquest-debug.apk` produce un APK instalable — si no, queda documentado como paso pendiente del usuario.
**Commit:** `chore: preset de export Android y guía de publicación en Play Store`

### Tarea 11.3 — README + verificación integral (spec §9)

1. `README.md`: qué es PromptQuest, cómo abrir el proyecto (Godot 4.6.3), cómo correr tests (`bash tools/test.sh`), cómo jugar (`bash tools/run.sh`), estructura de carpetas (tabla corta), link a la spec y a la guía de publicación.
2. Verificación integral manual en escritorio contra el criterio de éxito de la spec §9 — recorrer TODO como jugador nuevo (borrar el save primero: `%APPDATA%\Godot\app_userdata\PromptQuest\save.json`):
   - [ ] Intro se ve una sola vez y es saltable
   - [ ] Las 10 lecciones se juegan en orden, en ES y en EN
   - [ ] Errores restan corazones; a 0 corazones no se puede empezar lección nueva; repasar recupera 1
   - [ ] Cerrar y reabrir conserva progreso, XP y racha; el reloj regenera corazones
   - [ ] Boss: timer, regla 9/12, celebración de unidad completada
   - [ ] Sin crashes ni errores en consola en todo el recorrido
3. Registrar cualquier desvío encontrado como issue/tarea nueva antes de dar por cerrado el MVP.

**Commit:** `docs: README y verificación integral del MVP`

---

## Autorevisión del plan (hecha antes de la entrega)

1. **Cobertura de la spec:** economía §2.2 → Tareas 1.1–1.3/2.1/4.3 · desbloqueo §2.3 → 6.1 · boss §2.4 → 9.1 · narrativa/mascota §3 → 4.2/7.2/7.3 · curriculum §4 → 4.2/8.1–8.4/9.1 · arquitectura §5.1–5.3 → 0.1–2.1 · esquema contenido §5.4 → 1.5/4.2 · guardado §5.5 → 1.4 · i18n §5.6 → 7.1 · pantallas §6 → 3.2/4.3/4.4/6.1/7.2/7.3 · Play Store §7 → 11.2 · riesgos §8 → cubiertos (reloj atrasado 1.2, JSON corrupto 1.4/1.5, contenido validado 4.2).
2. **Desvío documentado respecto de la spec:** §5.6 pedía el sistema de Translation nativo (CSV) para la UI; el plan usa un `I18n` propio (Tarea 7.1) porque los `.translation` solo se generan importando desde el editor y romperían el flujo headless. Mismo resultado funcional (UI ES/EN en vivo). El otro ajuste: drag & drop → tap-to-place (Tarea 5.2), decisión de usabilidad anotada.
3. **Sin placeholders:** todas las tareas de código incluyen el código; las tareas de contenido (Fase 8/9.1) definen tema, conceptos exactos, cantidad y mezcla de ejercicios, con `lesson_01.json` completo como plantilla y un validador automático que las verifica.
4. **Consistencia de nombres verificada:** `EconomyRules.xp_por_leccion/estrellas/corazones_tras_regen/racha_tras_actividad/racha_vigente` · `SaveStore.persist` · `ContentLoader.localizar/cargar_leccion_cruda/validar_leccion` · `BlockLogic.armar_pool/es_correcta` · `ProgressLogic.estado` · señales `answered/continue_pressed/exit_pressed/hearts_changed` — usados igual en tests, implementaciones e integraciones.
5. **Riesgo conocido:** las claves exactas de `export_presets.cfg` varían por versión de Godot — por eso 11.2 lo genera desde el editor en vez de escribirlo a mano.

## Ejecución

Implementar tarea por tarea, en orden, con su commit cada una. Modos posibles:
- **Subagent-Driven** (recomendado): un subagente por tarea con revisión entre tareas — usar skill `subagent-driven-development`.
- **Inline**: ejecutar las tareas en esta misma sesión con checkpoints por fase — usar skill `executing-plans`.






