extends RefCounted
class_name TestCase
## Base de todos los tests. Métodos test_* son descubiertos por el runner.

var failures: Array[String] = []
var checks_ejecutados := 0

func check(cond: bool, msg: String) -> void:
	checks_ejecutados += 1
	if not cond:
		failures.append(msg)

func check_eq(got, want, msg: String = "") -> void:
	checks_ejecutados += 1
	if got != want:
		failures.append("%s (esperado: %s | obtuve: %s)" % [msg, str(want), str(got)])
