class_name UiTheme
## Sistema visual "neón tech oscuro": paleta, fábrica de controles, fondo con
## shader y bloom real. Cero assets externos (todo por código/GPU).

# --- Paleta ---
const FONDO := Color("0a0a1f")           # azul-noche profundo
const PANEL := Color("161636")           # panel translúcido base
const PANEL_BORDE := Color("2f2f66")     # borde/rim de paneles
const PRIMARIO := Color("46e661")        # verde neón (acción)
const PRIMARIO_HOVER := Color("6bf07f")
const ACENTO := Color("22c9ff")          # cian neón
const VIOLETA := Color("a06bff")         # violeta neón
const PELIGRO := Color("ff4d6d")         # rojo-rosa neón
const TEXTO := Color("eef2ff")
const TEXTO_SUAVE := Color("9096c8")
const DORADO := Color("ffcf3f")

# --- Shader de fondo (degradado + glows + grilla animada + viñeta) ---
const _SHADER_FONDO := "shader_type canvas_item;
void fragment() {
	vec2 uv = UV;
	vec3 top = vec3(0.05, 0.055, 0.14);
	vec3 bot = vec3(0.02, 0.015, 0.06);
	vec3 col = mix(top, bot, uv.y);
	float g1 = smoothstep(0.65, 0.0, distance(uv, vec2(0.5, 0.24)));
	col += g1 * 0.30 * vec3(0.10, 0.42, 0.85);
	float t = TIME * 0.06;
	vec2 p2 = vec2(0.82 + 0.05 * sin(t), 0.86 + 0.04 * cos(t * 1.2));
	col += smoothstep(0.5, 0.0, distance(uv, p2)) * 0.20 * vec3(0.5, 0.28, 0.95);
	vec2 p3 = vec2(0.18 + 0.05 * cos(t * 0.9), 0.62 + 0.05 * sin(t));
	col += smoothstep(0.4, 0.0, distance(uv, p3)) * 0.10 * vec3(0.12, 0.5, 0.9);
	vec2 grid = abs(fract(uv * vec2(9.0, 16.0)) - 0.5);
	col += smoothstep(0.49, 0.5, max(grid.x, grid.y)) * 0.018 * vec3(0.3, 0.6, 1.0);
	col *= mix(0.55, 1.0, smoothstep(1.15, 0.35, distance(uv, vec2(0.5, 0.5))));
	COLOR = vec4(col, 1.0);
}"

static var _shader_fondo_cache: Shader

static func _shader_fondo() -> Shader:
	if _shader_fondo_cache == null:
		_shader_fondo_cache = Shader.new()
		_shader_fondo_cache.code = _SHADER_FONDO
	return _shader_fondo_cache

static func fondo_pantalla(raiz: Control) -> void:
	# Un único ColorRect full-rect con material de shader (degradado + glows).
	var bg := ColorRect.new()
	bg.color = Color.WHITE  # el shader pinta todo; el color base no importa
	bg.material = ShaderMaterial.new()
	bg.material.shader = _shader_fondo()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	raiz.add_child(bg)
	raiz.move_child(bg, 0)

## Entorno con bloom para que el neón brille de verdad. Se agrega una vez por
## viewport (Main en el juego real; el harness de capturas lo replica).
static func crear_entorno_glow() -> WorldEnvironment:
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_strength = 1.05
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 0.85
	var we := WorldEnvironment.new()
	we.environment = env
	return we

# --- Styleboxes ---
static func _estilo(color: Color, radio: int = 18) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radio)
	s.set_content_margin_all(16)
	# rim light: borde superior más claro para dar volumen
	s.border_width_top = 2
	s.border_color = color.lightened(0.35)
	# glow del color, hacia abajo (profundidad)
	s.shadow_color = Color(color.r, color.g, color.b, 0.45)
	s.shadow_size = 14
	s.shadow_offset = Vector2(0, 5)
	s.anti_aliasing = true
	return s

static func _estilo_panel(color: Color, radio: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(color.r, color.g, color.b, 0.88)
	s.set_corner_radius_all(radio)
	s.set_content_margin_all(20)
	s.border_width_top = 1
	s.border_width_bottom = 1
	s.border_width_left = 1
	s.border_width_right = 1
	s.border_color = PANEL_BORDE
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 18
	s.shadow_offset = Vector2(0, 8)
	s.anti_aliasing = true
	return s

static func boton(texto: String, color: Color = PRIMARIO) -> Button:
	var b := Button.new()
	b.text = texto
	b.add_theme_stylebox_override("normal", _estilo(color))
	b.add_theme_stylebox_override("hover", _estilo(color.lightened(0.12)))
	b.add_theme_stylebox_override("pressed", _estilo(color.darkened(0.18)))
	b.add_theme_stylebox_override("disabled", _estilo(Color(color, 0.35)))
	# Mismo estilo que "normal": tapa el anillo de foco del theme default.
	b.add_theme_stylebox_override("focus", _estilo(color))
	var oscuro := color.get_luminance() > 0.5
	b.add_theme_color_override("font_color", Color("07230d") if oscuro else TEXTO)
	b.add_theme_color_override("font_hover_color", Color("07230d") if oscuro else TEXTO)
	b.add_theme_font_size_override("font_size", 26)
	b.custom_minimum_size = Vector2(0, 66)
	_animar_press(b)
	return b

static func _animar_press(b: Button) -> void:
	# Micro-interacción: el botón se hunde apenas al presionar.
	b.button_down.connect(func():
		b.pivot_offset = b.size / 2.0
		var t := b.create_tween()
		t.tween_property(b, "scale", Vector2(0.96, 0.96), 0.07))
	b.button_up.connect(func():
		var t := b.create_tween()
		t.tween_property(b, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))

static func etiqueta(texto: String, tam: int = 24, color: Color = TEXTO) -> Label:
	var l := Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tam)
	l.add_theme_color_override("font_color", color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

## Título grande con brillo (para encabezados de pantalla).
static func titulo(texto: String, tam: int = 34, color: Color = TEXTO) -> Label:
	var l := etiqueta(texto, tam, color)
	l.add_theme_color_override("font_outline_color", Color(color.r, color.g, color.b, 0.35))
	l.add_theme_constant_override("outline_size", 8)
	return l

static func panel(color: Color = PANEL, radio: int = 22) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _estilo_panel(color, radio))
	return p
