extends Control
class_name Mascot
## Byte: robot mascota blanco y azul con ojos cian que brillan (estilo robot de IA).
## animo: "neutral" | "feliz" | "triste" | "festejo". Dibujado a mano + bloom.

var animo := "neutral"
var _t := 0.0  # tiempo para el flotar idle

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

func _draw() -> void:
	var s := minf(size.x, size.y)
	var bob := sin(_t * 2.0) * s * 0.02
	var c := size / 2.0 + Vector2(0, bob)
	var cyan := UiTheme.ACENTO
	var brillo := UiTheme.DORADO if animo == "festejo" else cyan

	# --- aura ---
	var fuerza := 0.16 if animo == "festejo" else 0.09
	for k in 4:
		draw_circle(c, s * (0.44 + k * 0.08), Color(brillo.r, brillo.g, brillo.b, fuerza - k * 0.02))

	# --- antenas (dos, apenas abiertas, con punta que brilla) ---
	_antena(c + Vector2(-s * 0.14, -s * 0.34), c + Vector2(-s * 0.22, -s * 0.52), s, brillo)
	_antena(c + Vector2(s * 0.14, -s * 0.34), c + Vector2(s * 0.22, -s * 0.52), s, brillo)

	# --- orejas tipo auricular (a los costados, detrás de la cabeza) ---
	for lado in [-1.0, 1.0]:
		var e := c + Vector2(lado * s * 0.42, s * 0.02)
		draw_circle(e, s * 0.14, AZUL_OSC)
		draw_circle(e, s * 0.13, AZUL)
		draw_circle(e, s * 0.06, Color(cyan.r, cyan.g, cyan.b, 0.9))

	# --- cabeza: casco blanco con "corona" azul arriba ---
	draw_circle(c + Vector2(0, -s * 0.03), s * 0.42, AZUL)          # borde/corona azul
	draw_circle(c + Vector2(0, s * 0.04), s * 0.39, BLANCO_SOMBRA)  # sombra inferior
	draw_circle(c + Vector2(0, -s * 0.005), s * 0.385, BLANCO)      # casco blanco

	# --- cara (panel apenas hundido, claro) ---
	var cara := c + Vector2(0, s * 0.0)
	draw_circle(cara, s * 0.3, Color("e7ecfb"))

	# --- ojos grandes cian ---
	var oy := -s * 0.03
	if animo == "triste":
		oy = s * 0.0
	var sep := s * 0.145
	if animo == "triste":
		_ojo_triste(cara + Vector2(-sep, oy), s, cyan)
		_ojo_triste(cara + Vector2(sep, oy), s, cyan)
	else:
		_ojo(cara + Vector2(-sep, oy), s, cyan, brillo)
		_ojo(cara + Vector2(sep, oy), s, cyan, brillo)

	# --- cachetes cuando está contento ---
	if animo == "feliz" or animo == "festejo":
		var col_cache := Color(cyan.r, cyan.g, cyan.b, 0.45)
		draw_circle(cara + Vector2(-s * 0.24, s * 0.11), s * 0.05, col_cache)
		draw_circle(cara + Vector2(s * 0.24, s * 0.11), s * 0.05, col_cache)

	# --- boca ---
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
	# ojo grande: halo + anillo azul + cian brillante + pupila + destello
	draw_circle(p, s * 0.13, Color(brillo.r, brillo.g, brillo.b, 0.35))
	draw_circle(p, s * 0.1, AZUL_OSC)
	draw_circle(p, s * 0.085, cyan)
	draw_circle(p, s * 0.05, PUPILA)
	draw_circle(p + Vector2(-s * 0.02, -s * 0.02), s * 0.022, Color(1, 1, 1, 0.95))

func _ojo_triste(p: Vector2, s: float, cyan: Color) -> void:
	# ojo entrecerrado (más chico, con párpado)
	draw_circle(p, s * 0.075, AZUL_OSC)
	draw_circle(p, s * 0.06, cyan)
	draw_circle(p, s * 0.03, PUPILA)
	# párpado: tapa la mitad de arriba
	draw_arc(p, s * 0.09, deg_to_rad(180), deg_to_rad(360), 16, BLANCO, s * 0.06, true)
