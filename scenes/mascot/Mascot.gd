extends Control
class_name Mascot
## Byte: robot mascota blanco y azul con ojos cian (estilo robot de IA).
## animo: "neutral" | "feliz" | "triste" | "festejo".
## mostrar_cuerpo: false = solo cabeza (uso general) · true = cuerpo entero (intro/portada).

var animo := "neutral"
var mostrar_cuerpo := false
var _t := 0.0

const BLANCO := Color("f2f5ff")
const BLANCO_SOMBRA := Color("cdd6ec")
const AZUL := Color("2f74dd")
const AZUL_OSC := Color("184b95")
const PUPILA := Color("0b2440")

func set_animo(a: String) -> void:
	animo = a
	queue_redraw()
	pivot_offset = size / 2.0
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.16, 1.16), 0.12)
	t.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _brillo() -> Color:
	return UiTheme.DORADO if animo == "festejo" else UiTheme.ACENTO

func _draw() -> void:
	if mostrar_cuerpo:
		_draw_cuerpo()
	else:
		var s := minf(size.x, size.y)
		var c := size / 2.0 + Vector2(0, sin(_t * 2.0) * s * 0.02)
		_aura(c, s, _brillo())
		_cabeza(c, s)

func _aura(c: Vector2, s: float, brillo: Color) -> void:
	var fuerza := 0.16 if animo == "festejo" else 0.09
	for k in 4:
		draw_circle(c, s * (0.44 + k * 0.08), Color(brillo.r, brillo.g, brillo.b, fuerza - k * 0.02))

# ---------- cabeza ----------
func _cabeza(c: Vector2, s: float) -> void:
	var cyan := UiTheme.ACENTO
	var brillo := _brillo()
	_antena(c + Vector2(-s * 0.14, -s * 0.34), c + Vector2(-s * 0.22, -s * 0.52), s, brillo)
	_antena(c + Vector2(s * 0.14, -s * 0.34), c + Vector2(s * 0.22, -s * 0.52), s, brillo)
	for lado in [-1.0, 1.0]:
		var e := c + Vector2(lado * s * 0.42, s * 0.02)
		draw_circle(e, s * 0.14, AZUL_OSC)
		draw_circle(e, s * 0.13, AZUL)
		draw_circle(e, s * 0.06, Color(cyan.r, cyan.g, cyan.b, 0.9))
	draw_circle(c + Vector2(0, -s * 0.03), s * 0.42, AZUL)
	draw_circle(c + Vector2(0, s * 0.04), s * 0.39, BLANCO_SOMBRA)
	draw_circle(c + Vector2(0, -s * 0.005), s * 0.385, BLANCO)
	var cara := c
	draw_circle(cara, s * 0.3, Color("e7ecfb"))
	var oy := -s * 0.03
	if animo == "triste":
		oy = 0.0
	var sep := s * 0.145
	if animo == "triste":
		_ojo_triste(cara + Vector2(-sep, oy), s, cyan)
		_ojo_triste(cara + Vector2(sep, oy), s, cyan)
	else:
		_ojo(cara + Vector2(-sep, oy), s, cyan, brillo)
		_ojo(cara + Vector2(sep, oy), s, cyan, brillo)
	if animo == "feliz" or animo == "festejo":
		var cc := Color(cyan.r, cyan.g, cyan.b, 0.45)
		draw_circle(cara + Vector2(-s * 0.24, s * 0.11), s * 0.05, cc)
		draw_circle(cara + Vector2(s * 0.24, s * 0.11), s * 0.05, cc)
	match animo:
		"feliz", "festejo":
			draw_arc(cara + Vector2(0, s * 0.08), s * 0.13, deg_to_rad(20), deg_to_rad(160), 20, AZUL_OSC, s * 0.045, true)
		"triste":
			draw_arc(cara + Vector2(0, s * 0.2), s * 0.11, deg_to_rad(200), deg_to_rad(340), 20, Color("7893b8"), s * 0.035, true)
		_:
			draw_arc(cara + Vector2(0, s * 0.1), s * 0.09, deg_to_rad(30), deg_to_rad(150), 16, AZUL_OSC, s * 0.04, true)

func _antena(desde: Vector2, hasta: Vector2, s: float, brillo: Color) -> void:
	draw_line(desde, hasta, AZUL, s * 0.028)
	draw_circle(hasta, s * 0.055, brillo)
	draw_circle(hasta, s * 0.025, Color(1, 1, 1, 0.85))

func _ojo(p: Vector2, s: float, cyan: Color, brillo: Color) -> void:
	draw_circle(p, s * 0.13, Color(brillo.r, brillo.g, brillo.b, 0.35))
	draw_circle(p, s * 0.1, AZUL_OSC)
	draw_circle(p, s * 0.085, cyan)
	draw_circle(p, s * 0.05, PUPILA)
	draw_circle(p + Vector2(-s * 0.02, -s * 0.02), s * 0.022, Color(1, 1, 1, 0.95))

func _ojo_triste(p: Vector2, s: float, cyan: Color) -> void:
	draw_circle(p, s * 0.075, AZUL_OSC)
	draw_circle(p, s * 0.06, cyan)
	draw_circle(p, s * 0.03, PUPILA)
	draw_arc(p, s * 0.09, deg_to_rad(180), deg_to_rad(360), 16, BLANCO, s * 0.06, true)

# ---------- cuerpo entero ----------
func _draw_cuerpo() -> void:
	var w := size.x
	var h := size.y
	var bob := sin(_t * 2.0) * h * 0.012
	var cx := w * 0.5
	var cyan := UiTheme.ACENTO
	var brillo := _brillo()

	# aura detrás de toda la figura
	var fuerza := 0.15 if animo == "festejo" else 0.08
	for k in 4:
		draw_circle(Vector2(cx, h * 0.46 + bob), minf(w, h) * (0.42 + k * 0.09), Color(brillo.r, brillo.g, brillo.b, fuerza - k * 0.02))

	# piernas
	for lado in [-1.0, 1.0]:
		var cadera := Vector2(cx + lado * w * 0.08, h * 0.6 + bob)
		var rodilla := Vector2(cx + lado * w * 0.09, h * 0.72 + bob)
		var pie := Vector2(cx + lado * w * 0.09, h * 0.84 + bob)
		draw_line(cadera, pie, BLANCO, w * 0.075)
		draw_circle(rodilla, w * 0.045, AZUL)
		draw_circle(pie + Vector2(0, w * 0.01), w * 0.06, AZUL_OSC)

	# torso (cápsula blanca) + cuello azul + núcleo del pecho
	draw_line(Vector2(cx, h * 0.41 + bob), Vector2(cx, h * 0.57 + bob), BLANCO, w * 0.34)
	draw_line(Vector2(cx, h * 0.4 + bob), Vector2(cx, h * 0.42 + bob), AZUL, w * 0.24)  # cuello/collar
	var pecho := Vector2(cx, h * 0.49 + bob)
	draw_circle(pecho, w * 0.09, Color(cyan.r, cyan.g, cyan.b, 0.35))
	draw_circle(pecho, w * 0.06, AZUL_OSC)
	draw_circle(pecho, w * 0.04, cyan)

	# brazo izquierdo (al costado)
	var hombro_i := Vector2(cx - w * 0.16, h * 0.43 + bob)
	var codo_i := Vector2(cx - w * 0.22, h * 0.5 + bob)
	var mano_i := Vector2(cx - w * 0.24, h * 0.57 + bob)
	draw_line(hombro_i, mano_i, BLANCO, w * 0.075)
	draw_circle(codo_i, w * 0.04, AZUL)
	draw_circle(mano_i, w * 0.05, AZUL_OSC)

	# brazo derecho (levantado, señalando arriba)
	var hombro_d := Vector2(cx + w * 0.16, h * 0.43 + bob)
	var codo_d := Vector2(cx + w * 0.24, h * 0.36 + bob)
	var mano_d := Vector2(cx + w * 0.3, h * 0.25 + bob)
	draw_line(hombro_d, codo_d, BLANCO, w * 0.075)
	draw_line(codo_d, mano_d, BLANCO, w * 0.065)
	draw_circle(codo_d, w * 0.04, AZUL)
	draw_circle(mano_d, w * 0.05, AZUL_OSC)
	draw_circle(mano_d + Vector2(0, -w * 0.04), w * 0.022, cyan)  # dedo/señal que brilla

	# cabeza arriba
	var hs := h * 0.32
	_cabeza(Vector2(cx, h * 0.2 + bob), hs)
