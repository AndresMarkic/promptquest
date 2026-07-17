extends TestCase
## En Godot 4.6.3 los autoloads SÍ cargan en modo -s: cada corrida de tests
## inicializa SaveData/Economy. Este test garantiza que bajo el runner el
## guardado va a un archivo aparte y el save real del jugador queda intacto.

func test_savedata_usa_save_de_test_bajo_el_runner() -> void:
	check_eq(SaveData.store.path, "user://save_test.json",
		"bajo tests SaveData no debe tocar user://save.json")
