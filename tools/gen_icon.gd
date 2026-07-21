extends SceneTree
## Genera assets/icon.png (512x512, cara de Byte). Correr: bash tools/gen_icon.sh

func _initialize() -> void:
	var img := Image.create_empty(512, 512, false, Image.FORMAT_RGBA8)
	for y in 512:
		for x in 512:
			var d := Vector2(x - 256, y - 256).length()
			var col := Color("12122b")
			if d < 205.0: col = Color("1cb0f6")
			if d < 172.0: col = Color("0e2f4a")
			if Vector2(x - 195, y - 230).length() < 27.0: col = Color("9fe8ff")
			if Vector2(x - 317, y - 230).length() < 27.0: col = Color("9fe8ff")
			if absi(y - 325) < 13 and absi(x - 256) < 52: col = Color("9fe8ff")
			img.set_pixel(x, y, col)
	img.save_png("res://assets/icon.png")
	print("icono generado")
	quit(0)
