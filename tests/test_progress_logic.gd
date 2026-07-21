extends TestCase

const IDS := ["u1l01", "u1l02", "u1l03"]

func test_estados_iniciales() -> void:
	check_eq(ProgressLogic.estado("u1l01", IDS, {}), "actual", "la primera arranca jugable")
	check_eq(ProgressLogic.estado("u1l02", IDS, {}), "bloqueada", "la segunda arranca bloqueada")

func test_completar_desbloquea_la_siguiente() -> void:
	var avance := {"u1l01": {"stars": 2}}
	check_eq(ProgressLogic.estado("u1l01", IDS, avance), "completada", "con estrellas queda completada")
	check_eq(ProgressLogic.estado("u1l02", IDS, avance), "actual", "se desbloquea la siguiente")
	check_eq(ProgressLogic.estado("u1l03", IDS, avance), "bloqueada", "la tercera sigue bloqueada")
