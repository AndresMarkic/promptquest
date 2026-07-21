extends TestCase
## Integración del mapa, headless: que MapScreen se construya sin reventar y que
## los estados de los nodos reflejen el avance (patrón de test_ui_hud.gd).

const MAPA_ESCENA := "res://scenes/map/MapScreen.tscn"


func _raiz() -> Node:
	return (Engine.get_main_loop() as SceneTree).root


func _buscar_lesson_nodes(n: Node) -> Array:
	var out := []
	for h in n.get_children():
		if h is LessonNode:
			out.append(h)
		out.append_array(_buscar_lesson_nodes(h))
	return out


func _instanciar_mapa(cont: Node) -> Node:
	var mapa = (load(MAPA_ESCENA) as PackedScene).instantiate()
	cont.add_child(mapa)
	if not mapa.is_node_ready():
		mapa.notification(Node.NOTIFICATION_READY)
	return mapa


func test_mapa_con_save_fresco() -> void:
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()
	var cont := Node.new()
	_raiz().add_child(cont)
	var mapa := _instanciar_mapa(cont)
	# Con save fresco y solo lesson_01 existente en el MVP temprano, hay al menos
	# 1 nodo. (Fase 8/9 suman las demás lecciones; el test no fija el total.)
	var nodos := _buscar_lesson_nodes(mapa)
	check(nodos.size() >= 1, "el mapa construyó al menos un nodo de lección")
	cont.free()
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()


func test_mapa_con_leccion_1_completada() -> void:
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.data["lessons"] = {"u1l01": {"stars": 3}}
	SaveData.store.persist()
	var cont := Node.new()
	_raiz().add_child(cont)
	var mapa := _instanciar_mapa(cont)
	# El mapa no debe reventar con una lección ya completada (nodo "completada"
	# dibuja estrellas). La lógica fina de estados está en test_progress_logic.
	var nodos := _buscar_lesson_nodes(mapa)
	check(nodos.size() >= 1, "el mapa se arma con progreso guardado")
	cont.free()
	SaveData.store.data = SaveStore.DEFAULTS.duplicate(true)
	SaveData.store.persist()
