extends Control
class_name Mascot
## Byte: robot mascota dibujado a mano con sombreado, aura y flotar idle.
## animo: "neutral" | "feliz" | "triste" | "festejo"

var animo := "neutral"
var _t := 0.0  # tiempo para el flotar idle

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

func _draw() -> void:
	var s := minf(size.x, size.y)
	var bob := sin(_t * 2.0) * s * 0.02  # leve flotar
	var c := size / 2.0 + Vector2(0, bob)
	var aura := UiTheme.DORADO if animo == "festejo" else UiTheme.ACENTO

	# aura (varias capas suaves; el bloom la potencia)
	var fuerza := 0.16 if animo == "festejo" else 0.09
	for k in 4:
		draw_circle(c, s * (0.42 + k * 0.08), Color(aura.r, aura.g, aura.b, fuerza - k * 0.02))

	# antena con punta que brilla
	draw_line(c + Vector2(0, -s * 0.4), c + Vector2(0, -s * 0.54), UiTheme.ACENTO, s * 0.035)
	draw_circle(c + Vector2(0, -s * 0.56), s * 0.065, aura)
	draw_circle(c + Vector2(0, -s * 0.56), s * 0.03, Color(1, 1, 1, 0.8))

	# cuerpo: anillo neón + relleno con sombreado (círculo claro arriba)
	draw_circle(c, s * 0.4, UiTheme.ACENTO)
	draw_circle(c, s * 0.35, Color("0c2740"))
	draw_circle(c + Vector2(0, -s * 0.08), s * 0.3, Color("113755"))  # highlight superior

	# cara
	var oy := -s * 0.05
	if animo == "triste":
		oy = 0.0
	var col_ojo := UiTheme.DORADO if animo == "festejo" else Color("aef0ff")
	if animo == "feliz" or animo == "festejo":
		_ojo_feliz(c + Vector2(-s * 0.13, oy), s, col_ojo)
		_ojo_feliz(c + Vector2(s * 0.13, oy), s, col_ojo)
		# cachetes que brillan
		draw_circle(c + Vector2(-s * 0.22, s * 0.06), s * 0.055, Color(UiTheme.PRIMARIO.r, UiTheme.PRIMARIO.g, UiTheme.PRIMARIO.b, 0.5))
		draw_circle(c + Vector2(s * 0.22, s * 0.06), s * 0.055, Color(UiTheme.PRIMARIO.r, UiTheme.PRIMARIO.g, UiTheme.PRIMARIO.b, 0.5))
	else:
		draw_circle(c + Vector2(-s * 0.13, oy), s * 0.06, col_ojo)
		draw_circle(c + Vector2(s * 0.13, oy), s * 0.06, col_ojo)
		draw_circle(c + Vector2(-s * 0.11, oy - s * 0.02), s * 0.02, Color(1, 1, 1, 0.9))
		draw_circle(c + Vector2(s * 0.15, oy - s * 0.02), s * 0.02, Color(1, 1, 1, 0.9))

	# boca
	match animo:
		"feliz", "festejo":
			# sonrisa (arco)
			var pts := PackedVector2Array()
			for k in 9:
				var a := PI * (0.15 + 0.7 * k / 8.0)
				pts.append(c + Vector2(cos(a), sin(a)) * s * 0.17 + Vector2(0, s * 0.02))
			for k in pts.size() - 1:
				draw_line(pts[k], pts[k + 1], col_ojo, s * 0.03)
		"triste":
			var pts2 := PackedVector2Array()
			for k in 9:
				var a2 := PI + PI * (0.15 + 0.7 * k / 8.0)
				pts2.append(c + Vector2(cos(a2), sin(a2)) * s * 0.15 + Vector2(0, s * 0.2))
			for k in pts2.size() - 1:
				draw_line(pts2[k], pts2[k + 1], Color("7893b8"), s * 0.028)
		_:
			draw_rect(Rect2(c + Vector2(-s * 0.07, s * 0.12), Vector2(s * 0.14, s * 0.032)), col_ojo)

func _ojo_feliz(p: Vector2, s: float, col: Color) -> void:
	# ojo tipo arco (^) feliz
	var pts := PackedVector2Array()
	for k in 7:
		var a := PI * (0.15 + 0.7 * k / 6.0)
		pts.append(p + Vector2(cos(a), -sin(a)) * s * 0.07)
	for k in pts.size() - 1:
		draw_line(pts[k], pts[k + 1], col, s * 0.03)
