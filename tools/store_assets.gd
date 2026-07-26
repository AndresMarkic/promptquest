extends SceneTree
## Genera los assets de tienda (capturas + feature graphic + ícono) renderizando
## el juego real. Correr NO headless:
##   "$GODOT_EXE" --path . -s res://tools/store_assets.gd
## Salida en store/

var _save: Node
var _game: Node
var _feat_lang := "en"

func _initialize() -> void:
	_correr()

func _reset() -> void:
	_save.store.data = SaveStore.DEFAULTS.duplicate(true)

# ---- captura de una pantalla del juego (720x1280) ----
func _cap_pantalla(nombre: String, ruta: String, preparar: Callable, cerrar_intro := false) -> void:
	_reset()
	preparar.call()
	var escena = (load(ruta) as PackedScene).instantiate()
	root.add_child(escena)
	if cerrar_intro and escena.has_method("_cerrar_intro"):
		await process_frame
		escena._cerrar_intro()
	for i in 30:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://store/%s.png" % nombre)
	print("asset: ", nombre)
	escena.queue_free()
	await process_frame

# ---- render de un Control a un tamaño arbitrario vía SubViewport ----
func _render_control(nombre: String, tam: Vector2i, armar: Callable) -> void:
	var sv := SubViewport.new()
	sv.size = tam
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sv.transparent_bg = false
	root.add_child(sv)
	sv.add_child(UiTheme.crear_entorno_glow())
	var lienzo := Control.new()
	lienzo.size = Vector2(tam)
	sv.add_child(lienzo)
	armar.call(lienzo, Vector2(tam))
	for i in 24:
		await process_frame
	sv.get_texture().get_image().save_png("res://store/%s.png" % nombre)
	print("asset: ", nombre)
	sv.queue_free()
	await process_frame

func _correr() -> void:
	_save = root.get_node("SaveData")
	_game = root.get_node("Game")
	I18n.idioma_actual = "es"
	DirAccess.make_dir_recursive_absolute("res://store")
	root.add_child(UiTheme.crear_entorno_glow())

	# 1) Capturas del juego
	await _cap_pantalla("captura_1_mapa", "res://scenes/map/MapScreen.tscn", func():
		_save.store.data["lessons"] = {"u1l01": {"stars": 3}, "u1l02": {"stars": 3}, "u1l03": {"stars": 2}}
		_save.store.data["streak_days"] = 7
		_save.store.data["last_activity_date"] = Time.get_date_string_from_system()
		_save.store.data["xp_total"] = 142)

	await _cap_pantalla("captura_2_leccion", "res://scenes/lesson/LessonScreen.tscn", func():
		_game.params = {"lesson_id": "u1l01", "review": false}, true)

	await _cap_pantalla("captura_3_resultado", "res://scenes/ui/ResultScreen.tscn", func():
		_game.params = {"xp": 23, "estrellas": 3, "racha": 7, "sumo_racha": true,
			"byte_outro": "¡Recuperé mi primer fragmento de memoria!", "boss": false})

	await _cap_pantalla("captura_4_boss", "res://scenes/lesson/LessonScreen.tscn", func():
		_game.params = {"lesson_id": "u1l10", "review": false}, true)

	await _cap_pantalla("captura_5_certificacion", "res://scenes/ui/CertScreen.tscn", func():
		_save.store.data["xp_total"] = 1580
		_game.params = {"xp": 1580, "boss": true})

	# 2) Feature graphic 1024x500
	_feat_lang = "en"
	await _render_control("feature_graphic", Vector2i(1024, 500), _armar_feature)
	_feat_lang = "es"
	await _render_control("feature_graphic_es", Vector2i(1024, 500), _armar_feature)

	# 3) Ícono 512x512
	await _render_control("icono_512", Vector2i(512, 512), _armar_icono)

	print("LISTO")
	quit(0)

func _armar_feature(lienzo: Control, tam: Vector2) -> void:
	UiTheme.fondo_pantalla(lienzo)
	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(360, 360)
	byte.size = Vector2(360, 360)
	byte.position = Vector2(90, tam.y / 2 - 180)
	byte.mostrar_cuerpo = true
	lienzo.add_child(byte)
	byte.set_animo("festejo")

	# Labels con posición absoluta y autowrap OFF (un VBox sin ancho parte el texto).
	var t := UiTheme.titulo("PromptQuest", 78, UiTheme.ACENTO)
	t.autowrap_mode = TextServer.AUTOWRAP_OFF
	t.position = Vector2(430, 158)
	lienzo.add_child(t)
	var textos: Array = {
		"en": ["Learn to use AI by playing", "From zero to AI engineer · free & open source"],
		"es": ["Aprendé a usar la IA jugando", "De cero a ingeniero · gratis y open source"],
	}[_feat_lang]
	var s1 := UiTheme.etiqueta(textos[0], 32, UiTheme.TEXTO)
	s1.autowrap_mode = TextServer.AUTOWRAP_OFF
	s1.position = Vector2(432, 268)
	lienzo.add_child(s1)
	var s2 := UiTheme.etiqueta(textos[1], 23, UiTheme.PRIMARIO)
	s2.autowrap_mode = TextServer.AUTOWRAP_OFF
	s2.position = Vector2(432, 314)
	lienzo.add_child(s2)

func _armar_icono(lienzo: Control, tam: Vector2) -> void:
	var bg := ColorRect.new()
	bg.color = UiTheme.FONDO
	bg.size = tam
	lienzo.add_child(bg)
	# glows de fondo
	var byte: Mascot = load("res://scenes/mascot/Mascot.tscn").instantiate()
	byte.custom_minimum_size = Vector2(400, 400)
	byte.size = Vector2(400, 400)
	byte.position = tam / 2 - Vector2(200, 200)
	lienzo.add_child(byte)
	byte.set_animo("feliz")
