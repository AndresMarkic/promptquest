extends TestCase
## Certificación final: detección del boss final y construcción de la pantalla.

func test_es_leccion_final() -> void:
	check_eq(Content.es_leccion_final("u8l10"), true, "el boss de la unidad 8 es la final")
	check_eq(Content.es_leccion_final("u1l10"), false, "el boss de la unidad 1 no es la final")
	check_eq(Content.es_leccion_final("u8l09"), false, "una lección normal de la 8 no es final")
	check_eq(Content.es_leccion_final("u2l05"), false, "una lección intermedia no es final")

func test_cert_screen_se_construye() -> void:
	var raiz := (Engine.get_main_loop() as SceneTree).root
	var cont := Node.new()
	raiz.add_child(cont)
	Game.params = {"xp": 500, "boss": true}
	var cert = (load("res://scenes/ui/CertScreen.tscn") as PackedScene).instantiate()
	cont.add_child(cert)
	if not cert.is_node_ready():
		cert.notification(Node.NOTIFICATION_READY)
	check(cert.get_child_count() >= 2, "la certificación construyó su UI")
	cont.free()
