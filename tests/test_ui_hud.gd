extends TestCase
## Fase 3: el juego todavía no instancia el HUD ni las fábricas de UI;
## este test los ejercita headless para atrapar errores de API/parseo.

const HUD_ESCENA := "res://scenes/ui/Hud.tscn"


func _raiz() -> Node:
	# Los tests corren bajo el runner (-s, extends SceneTree): el árbol vivo
	# se obtiene vía Engine.get_main_loop().
	return (Engine.get_main_loop() as SceneTree).root


func test_hud_instancia_y_actualiza() -> void:
	var contenedor := Node.new()
	_raiz().add_child(contenedor)
	var hud: Hud = (load(HUD_ESCENA) as PackedScene).instantiate()
	contenedor.add_child(hud)
	if not hud.is_node_ready():
		# Bajo el runner (-s) la raíz del árbol todavía no está "ready" durante
		# _initialize, así que add_child no dispara _ready(): se notifica a mano.
		hud.notification(Node.NOTIFICATION_READY)

	check_eq(hud.mouse_filter, Control.MOUSE_FILTER_IGNORE,
		"la raíz del Hud debe ignorar el mouse (si no, se traga los clicks del ejercicio)")

	hud.set_progreso(3, 10)
	check_eq(hud._barra.max_value, 10.0, "set_progreso actualiza el máximo")
	check_eq(hud._barra.value, 3.0, "set_progreso actualiza el valor")

	hud.set_corazones(2)
	check_eq(hud._cont_corazones.get_child_count(), EconomyRules.MAX_CORAZONES,
		"set_corazones deja exactamente MAX_CORAZONES iconos")
	hud.set_corazones(4)
	check_eq(hud._cont_corazones.get_child_count(), EconomyRules.MAX_CORAZONES,
		"llamadas repetidas no acumulan corazones (remove_child antes de queue_free)")

	hud.set_combo(5)
	check_eq(hud._lbl_combo.text, "¡Combo x5!", "set_combo >= 3 muestra el texto")
	hud.set_combo(2)
	check_eq(hud._lbl_combo.text, "", "combo < 3 no muestra nada")

	contenedor.free()  # libera el hud en cascada


func test_uitheme_fabricas() -> void:
	var b := UiTheme.boton("Probar")
	check(b is Button, "boton devuelve un Button")
	check(b.has_theme_stylebox_override("focus"),
		"boton pisa el stylebox focus (anillo del theme default)")
	var l := UiTheme.etiqueta("hola")
	check(l is Label, "etiqueta devuelve un Label")
	var p := UiTheme.panel()
	check(p is PanelContainer, "panel devuelve un PanelContainer")

	var raiz := Control.new()
	UiTheme.fondo_pantalla(raiz)
	check_eq(raiz.get_child_count(), 1, "fondo_pantalla agrega el fondo")
	var bg := raiz.get_child(0) as ColorRect
	check(bg != null, "el fondo es un ColorRect")
	if bg != null:
		check_eq(bg.mouse_filter, Control.MOUSE_FILTER_IGNORE,
			"el fondo decorativo no debe tragarse los clicks")

	b.free()
	l.free()
	p.free()
	raiz.free()


func test_iconos_se_instancian() -> void:
	var contenedor := Node.new()
	_raiz().add_child(contenedor)
	for t in ["corazon", "fuego", "estrella"]:
		var i := Icono.nuevo(t)
		check(i is Icono, "Icono.nuevo(%s) instancia" % t)
		check_eq(i.tipo, t, "Icono.nuevo asigna el tipo %s" % t)
		contenedor.add_child(i)
	check_eq(contenedor.get_child_count(), 3, "los 3 iconos entran al árbol sin error")
	contenedor.free()
