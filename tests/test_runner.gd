extends SceneTree
## Corre headless: godot --headless --path . -s res://tests/test_runner.gd

func _initialize() -> void:
	var total := 0
	var fallas := 0
	var dir := DirAccess.open("res://tests")
	var archivos := Array(dir.get_files())
	archivos.sort()
	for f in archivos:
		if not (f.begins_with("test_") and f.ends_with(".gd")):
			continue
		if f in ["test_runner.gd", "test_case.gd"]:
			continue
		var t = load("res://tests/" + f).new()
		for m in t.get_method_list():
			if not m.name.begins_with("test_"):
				continue
			t.failures.clear()
			t.call(m.name)
			total += 1
			if t.failures.is_empty():
				print("OK   %s :: %s" % [f, m.name])
			else:
				fallas += 1
				print("FALLA %s :: %s" % [f, m.name])
				for msg in t.failures:
					print("      - " + msg)
	print("== %d tests, %d fallas ==" % [total, fallas])
	quit(1 if fallas > 0 else 0)
