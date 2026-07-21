extends TestCase
## Fase 10: síntesis de sonido. La reproducción real no se testea headless; se
## verifica que el WAV se genera bien y que llamar los sonidos sin player no crashea.

func test_melodia_genera_wav_valido() -> void:
	var wav := Audio._melodia([440.0])
	check(wav is AudioStreamWAV, "genera un AudioStreamWAV")
	check_eq(wav.format, AudioStreamWAV.FORMAT_16_BITS, "formato 16 bits")
	check(wav.data.size() > 0, "tiene muestras de audio")

func test_tocar_sin_player_no_crashea() -> void:
	# Bajo el runner Audio._player es null: los sonidos deben ser un no-op seguro.
	Audio.acierto()
	Audio.error()
	Audio.festejo()
	check(true, "llamar sonidos sin player inicializado no crashea")
