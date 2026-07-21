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
		# ojos como arcos felices (dos rectángulos finos)
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
