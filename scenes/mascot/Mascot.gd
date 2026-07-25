extends Control
class_name Mascot
## "Chispa": la mascota es una chispa/estrella de 4 puntas con carita (el símbolo
## moderno de la IA, la "chispa de inteligencia"). animo: neutral|feliz|triste|festejo.
## mostrar_cuerpo suma chispitas orbitando para los planos grandes (intro/portada).

var animo := "neutral"
var mostrar_cuerpo := false
var _t := 0.0

const CHISPA := Color("35d6ff")       # cian brillante (cuerpo)
const CHISPA_CORE := Color("e9fbff")  # casi blanco (núcleo)
const OSCURO := Color("0b2440")       # rasgos de la cara
const CACHETE := Color(1.0, 0.62, 0.72, 0.55)

func set_animo(a: String) -> void:
	animo = a
	queue_redraw()
	pivot_offset = size / 2.0
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.18, 1.18), 0.12)
	t.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _brillo() -> Color:
	return UiTheme.DORADO if animo == "festejo" else UiTheme.ACENTO

func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size / 2.0 + Vector2(0, sin(_t * 2.0) * s * 0.03)
	var brillo := _brillo()

	# aura (glow); más fuerte en festejo, más tenue en triste
	var fuerza := 0.18 if animo == "festejo" else (0.06 if animo == "triste" else 0.11)
	for k in 4:
		draw_circle(c, s * (0.4 + k * 0.09), Color(brillo.r, brillo.g, brillo.b, fuerza - k * 0.025))

	# chispitas orbitando (planos grandes o festejo)
	if mostrar_cuerpo or animo == "festejo":
		for i in 3:
			var ang := _t * 1.1 + i * TAU / 3.0
			var pos := c + Vector2(cos(ang), sin(ang)) * s * 0.52
			_estrella4(pos, s * 0.07, s * 0.022, Color(brillo.r, brillo.g, brillo.b, 0.9))

	# chispa principal (cuerpo) + núcleo brillante
	var cuerpo := brillo if animo == "festejo" else CHISPA
	_estrella4(c, s * 0.44, s * 0.08, cuerpo)
	_estrella4(c, s * 0.28, s * 0.055, CHISPA_CORE)

	_cara(c, s)

# Chispa de 4 puntas = dos rombos cruzados (formas convexas → robusto).
func _estrella4(c: Vector2, largo: float, ancho: float, col: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -largo), c + Vector2(ancho, 0),
		c + Vector2(0, largo), c + Vector2(-ancho, 0)]), col)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-largo, 0), c + Vector2(0, ancho),
		c + Vector2(largo, 0), c + Vector2(0, -ancho)]), col)

func _cara(c: Vector2, s: float) -> void:
	var oy := -s * 0.01
	if animo == "triste":
		oy = s * 0.02
	var sep := s * 0.082
	if animo == "feliz" or animo == "festejo":
		_ojo_feliz(c + Vector2(-sep, oy), s)
		_ojo_feliz(c + Vector2(sep, oy), s)
		draw_circle(c + Vector2(-s * 0.15, s * 0.05), s * 0.032, CACHETE)
		draw_circle(c + Vector2(s * 0.15, s * 0.05), s * 0.032, CACHETE)
	else:
		draw_circle(c + Vector2(-sep, oy), s * 0.043, OSCURO)
		draw_circle(c + Vector2(sep, oy), s * 0.043, OSCURO)
		draw_circle(c + Vector2(-sep - s * 0.012, oy - s * 0.014), s * 0.016, Color(1, 1, 1, 0.9))
		draw_circle(c + Vector2(sep - s * 0.012, oy - s * 0.014), s * 0.016, Color(1, 1, 1, 0.9))
	match animo:
		"feliz", "festejo":
			draw_arc(c + Vector2(0, s * 0.05), s * 0.06, deg_to_rad(25), deg_to_rad(155), 18, OSCURO, s * 0.022, true)
		"triste":
			draw_arc(c + Vector2(0, s * 0.12), s * 0.05, deg_to_rad(205), deg_to_rad(335), 18, OSCURO, s * 0.02, true)
		_:
			draw_arc(c + Vector2(0, s * 0.06), s * 0.045, deg_to_rad(35), deg_to_rad(145), 14, OSCURO, s * 0.018, true)

func _ojo_feliz(p: Vector2, s: float) -> void:
	draw_arc(p, s * 0.05, deg_to_rad(200), deg_to_rad(340), 12, OSCURO, s * 0.02, true)
