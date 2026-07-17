extends RefCounted
class_name TestCase
## Base de todos los tests. Métodos test_* son descubiertos por el runner.

var failures: Array[String] = []

func check(cond: bool, msg: String) -> void:
	if not cond:
		failures.append(msg)

func check_eq(got, want, msg: String = "") -> void:
	if got != want:
		failures.append("%s (esperado: %s | obtuve: %s)" % [msg, str(want), str(got)])
