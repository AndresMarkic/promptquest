class_name UiTheme
## Paleta y fábrica de controles con estilo consistente. Cero assets externos.

const FONDO := Color("12122b")
const PANEL := Color("1e1e42")
const PRIMARIO := Color("58cc02")      # verde acción (estilo Duolingo)
const PRIMARIO_HOVER := Color("6ee014")
const ACENTO := Color("1cb0f6")        # celeste
const PELIGRO := Color("ff4b4b")
const TEXTO := Color("f5f5ff")
const TEXTO_SUAVE := Color("a0a0c0")
const DORADO := Color("ffc800")

static func fondo_pantalla(raiz: Control) -> void:
	var bg := ColorRect.new()
	bg.color = FONDO
	# Decorativo: con el STOP default un fondo full-rect se traga los clicks
	# de todo lo que quede detrás de la pantalla.
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(bg)
	raiz.move_child(bg, 0)

static func _estilo(color: Color, radio: int = 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radio)
	s.set_content_margin_all(16)
	return s

static func boton(texto: String, color: Color = PRIMARIO) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_stylebox_override("normal", _estilo(color))
	b.add_theme_stylebox_override("hover", _estilo(color.lightened(0.1)))
	b.add_theme_stylebox_override("pressed", _estilo(color.darkened(0.2)))
	b.add_theme_stylebox_override("disabled", _estilo(Color(color, 0.4)))
	# Mismo estilo que "normal": sin esto el anillo de foco del theme default
	# se dibuja encima del estilo custom al navegar con teclado/click.
	b.add_theme_stylebox_override("focus", _estilo(color))
	b.add_theme_color_override("font_color", Color("0f2a00") if color == PRIMARIO else TEXTO)
	b.add_theme_font_size_override("font_size", 26)
	b.custom_minimum_size = Vector2(0, 64)
	return b

static func etiqueta(texto: String, tam: int = 24, color: Color = TEXTO) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

static func panel(color: Color = PANEL, radio: int = 20) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _estilo(color, radio))
	return p
