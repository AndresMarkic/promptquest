class_name Icono
extends Control
## Dibuja corazón / fuego / estrella sin assets. tipo: "corazon"|"fuego"|"estrella"

var tipo := "corazon"
var activo := true

static func nuevo(p_tipo: String, p_activo: bool = true, tam: float = 28.0) -> Icono:
	var i := Icono.new()
	i.tipo = p_tipo
	i.activo = p_activo
	i.custom_minimum_size = Vector2(tam, tam)
	return i

func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size / 2.0
	match tipo:
		"corazon":
			var col := UiTheme.PELIGRO if activo else Color("3a3a5c")
			draw_circle(c + Vector2(-s * 0.18, -s * 0.12), s * 0.22, col)
			draw_circle(c + Vector2(s * 0.18, -s * 0.12), s * 0.22, col)
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(-s * 0.38, -0.02 * s), c + Vector2(s * 0.38, -0.02 * s),
				c + Vector2(0, s * 0.42)]), col)
		"fuego":
			draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -s * 0.45), c + Vector2(s * 0.32, s * 0.1),
				c + Vector2(0, s * 0.45), c + Vector2(-s * 0.32, s * 0.1)]),
				Color("ff9600") if activo else Color("3a3a5c"))
			draw_circle(c + Vector2(0, s * 0.12), s * 0.16, UiTheme.DORADO if activo else Color("55557a"))
		"estrella":
			var pts := PackedVector2Array()
			for k in 10:
				var ang := -PI / 2 + k * PI / 5.0
				var r := s * (0.48 if k % 2 == 0 else 0.20)
				pts.append(c + Vector2(cos(ang), sin(ang)) * r)
			draw_colored_polygon(pts, UiTheme.DORADO if activo else Color("3a3a5c"))
