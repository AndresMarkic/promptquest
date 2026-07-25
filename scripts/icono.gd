class_name Icono
extends Control
## Iconos vectoriales con brillo (el bloom del entorno los hace glow de verdad).
## tipo: "corazon" | "fuego" | "estrella" | "diamante"

var tipo := "corazon"
var activo := true

static func nuevo(p_tipo: String, p_activo: bool = true, tam: float = 30.0) -> Icono:
	var i := Icono.new()
	i.tipo = p_tipo
	i.activo = p_activo
	i.custom_minimum_size = Vector2(tam, tam)
	i.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return i

const _GRIS := Color("363658")

func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size / 2.0
	match tipo:
		"corazon":
			_corazon(c, s)
		"fuego":
			_fuego(c, s)
		"estrella":
			_estrella(c, s, 0.48, 0.20)
		"diamante":
			_diamante(c, s)
		"engranaje":
			_engranaje(c, s)

func _halo(c: Vector2, r: float, col: Color) -> void:
	# Halo suave (varias capas) para reforzar el brillo aun sin bloom.
	if not activo:
		return
	for k in 3:
		draw_circle(c, r * (1.0 + 0.28 * (k + 1)), Color(col.r, col.g, col.b, 0.10 - k * 0.03))

func _corazon(c: Vector2, s: float) -> void:
	var col := UiTheme.PELIGRO if activo else _GRIS
	_halo(c, s * 0.3, col)
	var izq := c + Vector2(-s * 0.18, -s * 0.1)
	var der := c + Vector2(s * 0.18, -s * 0.1)
	draw_circle(izq, s * 0.23, col)
	draw_circle(der, s * 0.23, col)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-s * 0.4, 0.0), c + Vector2(s * 0.4, 0.0),
		c + Vector2(0.0, s * 0.44)]), col)
	if activo:  # brillo especular
		draw_circle(izq + Vector2(-s * 0.05, -s * 0.06), s * 0.06, Color(1, 1, 1, 0.55))

func _fuego(c: Vector2, s: float) -> void:
	var base := Color("ff7a18") if activo else _GRIS
	_halo(c, s * 0.28, Color("ff9a2e"))
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -s * 0.48), c + Vector2(s * 0.3, s * 0.02),
		c + Vector2(s * 0.2, s * 0.34), c + Vector2(0, s * 0.44),
		c + Vector2(-s * 0.2, s * 0.34), c + Vector2(-s * 0.3, s * 0.02)]), base)
	if activo:
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(0, -s * 0.2), c + Vector2(s * 0.16, s * 0.1),
			c + Vector2(0, s * 0.32), c + Vector2(-s * 0.16, s * 0.1)]), UiTheme.DORADO)
		draw_circle(c + Vector2(0, s * 0.16), s * 0.1, Color("fff4c2"))

func _estrella(c: Vector2, s: float, r_ext: float, r_int: float) -> void:
	var col := UiTheme.DORADO if activo else _GRIS
	_halo(c, s * r_ext, col)
	var pts := PackedVector2Array()
	for k in 10:
		var ang := -PI / 2 + k * PI / 5.0
		var r := s * (r_ext if k % 2 == 0 else r_int)
		pts.append(c + Vector2(cos(ang), sin(ang)) * r)
	draw_colored_polygon(pts, col)
	if activo:
		draw_circle(c + Vector2(-s * 0.05, -s * 0.05), s * 0.09, Color(1, 1, 1, 0.5))

func _engranaje(c: Vector2, s: float) -> void:
	var col := UiTheme.TEXTO_SUAVE if activo else _GRIS
	for k in 8:
		var a := k * PI / 4.0
		draw_circle(c + Vector2(cos(a), sin(a)) * s * 0.34, s * 0.1, col)
	draw_circle(c, s * 0.3, col)
	draw_circle(c, s * 0.13, UiTheme.ACENTO if activo else _GRIS)

func _diamante(c: Vector2, s: float) -> void:
	var col := UiTheme.ACENTO if activo else _GRIS
	_halo(c, s * 0.3, col)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, -s * 0.4), c + Vector2(s * 0.34, -s * 0.06),
		c + Vector2(0, s * 0.44), c + Vector2(-s * 0.34, -s * 0.06)]), col)
	if activo:
		draw_colored_polygon(PackedVector2Array([
			c + Vector2(0, -s * 0.4), c + Vector2(s * 0.12, -s * 0.06),
			c + Vector2(-s * 0.12, -s * 0.06)]), Color(1, 1, 1, 0.45))
