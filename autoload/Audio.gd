extends Node
## Autoload. Efectos de sonido sintetizados por código: cero assets binarios.

var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)

func _activo() -> bool:
	return SaveData.get_value("settings", {"sound": true}).get("sound", true)

func acierto() -> void: _tocar([880.0])
func error() -> void: _tocar([196.0])
func festejo() -> void: _tocar([523.25, 659.25, 783.99, 1046.5])

func _tocar(frecuencias: Array) -> void:
	# _player se crea en _ready; bajo el runner (-s) puede no existir todavía.
	if _player == null or not _activo():
		return
	_player.stream = _melodia(frecuencias)
	_player.play()

func _melodia(frecuencias: Array, dur := 0.12) -> AudioStreamWAV:
	var hz := 22050
	var n_nota := int(dur * hz)
	var bytes := PackedByteArray()
	bytes.resize(n_nota * frecuencias.size() * 2)
	var idx := 0
	for f in frecuencias:
		for i in n_nota:
			var envolvente := 1.0 - float(i) / n_nota  # fade out por nota
			var v := int(sin(TAU * f * i / hz) * 32767.0 * 0.35 * envolvente)
			bytes.encode_s16(idx * 2, v)
			idx += 1
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = hz
	wav.data = bytes
	return wav
