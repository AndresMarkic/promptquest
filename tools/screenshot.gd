extends SceneTree
## Renderiza cada pantalla del juego a PNG para iterar el diseño contra la captura.
## Correr NO headless (necesita render):
##   "$GODOT_EXE" --path . -s res://tools/screenshot.gd
## Guarda en capturas/<pantalla>.png
## Nota: los autoloads no son visibles como globales al compilar el script de
## entrada -s, así que se toman por get_node en runtime.

var _save: Node
var _game: Node
var _content: Node

func _initialize() -> void:
	_correr()

func _reset_save() -> void:
	_save.store.data = SaveStore.DEFAULTS.duplicate(true)

func _capturar(nombre: String, escena_ruta: String, preparar: Callable) -> void:
	_reset_save()
	preparar.call()
	var escena = (load(escena_ruta) as PackedScene).instantiate()
	root.add_child(escena)
	if escena.has_method("_cerrar_intro"):
		await process_frame
		escena._cerrar_intro()
	for i in 20:
		await process_frame
	var img := root.get_viewport().get_texture().get_image()
	img.save_png("res://capturas/%s.png" % nombre)
	print("captura: ", nombre)
	escena.queue_free()
	await process_frame
	await process_frame

func _correr() -> void:
	_save = root.get_node("SaveData")
	_game = root.get_node("Game")
	_content = root.get_node("Content")
	I18n.idioma_actual = "es"
	DirAccess.make_dir_recursive_absolute("res://capturas")
	# Bloom, igual que en el juego real, para que las capturas muestren el neón.
	root.add_child(UiTheme.crear_entorno_glow())

	await _capturar("intro", "res://scenes/intro/IntroScreen.tscn", func(): pass)

	await _capturar("mapa", "res://scenes/map/MapScreen.tscn", func():
		# Unidad 1 completa → se ve la transición a la zona 2 (LA FORJA).
		var lecs := {}
		for n in range(1, 11):
			lecs["u1l%02d" % n] = {"stars": 3 if n <= 7 else 2}
		_save.store.data["lessons"] = lecs
		_save.store.data["streak_days"] = 7
		_save.store.data["last_activity_date"] = Time.get_date_string_from_system()
		_save.store.data["xp_total"] = 210)

	await _capturar("leccion", "res://scenes/lesson/LessonScreen.tscn", func():
		_game.params = {"lesson_id": "u1l01", "review": false})

	await _capturar("resultado", "res://scenes/ui/ResultScreen.tscn", func():
		_game.params = {"xp": 23, "estrellas": 3, "racha": 5, "sumo_racha": true,
			"byte_outro": "¡Recuperé mi primer fragmento de memoria!", "boss": false})

	await _capturar("ajustes", "res://scenes/ui/SettingsPanel.tscn", func(): pass)

	await _capturar("certificacion", "res://scenes/ui/CertScreen.tscn", func():
		_game.params = {"xp": 1580, "boss": true})

	# captura del mapa scrolleado a la transición EL NÚCLEO → LA FORJA
	await _cap_mapa_transicion()

	# capturas de zonas profundas (variedad de color): todo completado
	await _cap_zonas()

	# prueba de responsive: distintas proporciones de teléfono
	await _cap_responsive()

	# verificación del inglés (que no quede nada en español)
	await _cap_ingles()

	print("LISTO")
	quit(0)

func _cap_ingles() -> void:
	I18n.idioma_actual = "en"
	# mapa con unidad 1 completa (para ver zonas y transición en inglés)
	_reset_save()
	_save.store.data["language"] = "en"
	var lecs := {}
	for n in range(1, 11):
		lecs["u1l%02d" % n] = {"stars": 3}
	_save.store.data["lessons"] = lecs
	_save.store.data["xp_total"] = 210
	var mapa = (load("res://scenes/map/MapScreen.tscn") as PackedScene).instantiate()
	root.add_child(mapa)
	for i in 12:
		await process_frame
	var sc := _buscar_scroll(mapa)
	if sc != null:
		sc.scroll_vertical = 1360
	for i in 12:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://capturas/en_mapa.png")
	print("captura: en_mapa")
	mapa.queue_free()
	await process_frame
	# una lección en inglés
	_reset_save()
	_save.store.data["language"] = "en"
	_game.params = {"lesson_id": "u1l01", "review": false}
	var lec = (load("res://scenes/lesson/LessonScreen.tscn") as PackedScene).instantiate()
	root.add_child(lec)
	await process_frame
	if lec.has_method("_cerrar_intro"):
		lec._cerrar_intro()
	for i in 14:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://capturas/en_leccion.png")
	print("captura: en_leccion")
	lec.queue_free()
	await process_frame
	I18n.idioma_actual = "es"

func _cap_responsive() -> void:
	# teléfono muy alto (9:19.5) y uno más bajo (3:5), para verificar centrado
	var tamanos := {"alto": Vector2i(1080, 2340), "bajo": Vector2i(1080, 1620)}
	for etiqueta in tamanos:
		root.size = tamanos[etiqueta]
		for i in 6:
			await process_frame
		# intro (centrado vertical)
		_reset_save()
		var intro = (load("res://scenes/intro/IntroScreen.tscn") as PackedScene).instantiate()
		root.add_child(intro)
		for i in 14:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("res://capturas/resp_intro_%s.png" % etiqueta)
		print("captura: resp_intro_", etiqueta)
		intro.queue_free()
		await process_frame
		# mapa
		_reset_save()
		_save.store.data["lessons"] = {"u1l01": {"stars": 3}}
		var mapa = (load("res://scenes/map/MapScreen.tscn") as PackedScene).instantiate()
		root.add_child(mapa)
		for i in 12:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("res://capturas/resp_mapa_%s.png" % etiqueta)
		print("captura: resp_mapa_", etiqueta)
		mapa.queue_free()
		await process_frame
	root.size = Vector2i(1080, 1920)  # restaurar
	await process_frame

func _cap_zonas() -> void:
	_reset_save()
	var lecs := {}
	for u in range(1, 9):
		for n in range(1, 11):
			lecs["u%dl%02d" % [u, n]] = {"stars": 3}
	_save.store.data["lessons"] = lecs
	_save.store.data["xp_total"] = 1580
	var mapa = (load("res://scenes/map/MapScreen.tscn") as PackedScene).instantiate()
	root.add_child(mapa)
	for i in 10:
		await process_frame
	var sc := _buscar_scroll(mapa)
	# zona 3 (El Taller, verde), zona 6 (El Crisol, rojo), zona 8 (La Cima, dorado)
	var destinos := {"zona_taller": 3560, "zona_crisol": 8990, "zona_cima": 12610}
	for nombre in destinos:
		if sc != null:
			sc.scroll_vertical = destinos[nombre]
		for i in 10:
			await process_frame
		root.get_viewport().get_texture().get_image().save_png("res://capturas/%s.png" % nombre)
		print("captura: ", nombre)
	mapa.queue_free()
	await process_frame

func _buscar_scroll(n: Node) -> ScrollContainer:
	for h in n.get_children():
		if h is ScrollContainer:
			return h
		var r := _buscar_scroll(h)
		if r != null:
			return r
	return null

func _cap_mapa_transicion() -> void:
	_reset_save()
	var lecs := {}
	for n in range(1, 11):
		lecs["u1l%02d" % n] = {"stars": 3}
	_save.store.data["lessons"] = lecs
	_save.store.data["streak_days"] = 7
	_save.store.data["xp_total"] = 210
	var mapa = (load("res://scenes/map/MapScreen.tscn") as PackedScene).instantiate()
	root.add_child(mapa)
	for i in 10:
		await process_frame
	var sc := _buscar_scroll(mapa)
	if sc != null:
		sc.scroll_vertical = 1360  # ~fin de la zona 1 / inicio de la zona 2
	for i in 14:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://capturas/mapa_transicion.png")
	print("captura: mapa_transicion")
	mapa.queue_free()
	await process_frame
