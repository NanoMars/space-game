extends Node

var damage_sound: DefinedSound = DefinedSound.new()
var player_gunshot: DefinedSound = DefinedSound.new()


func _ready() -> void:
	damage_sound.sound = preload("res://game/sound/damage1.ogg")
	damage_sound.volume = 1.0

	player_gunshot.sound = preload("res://game/sound/Gunshot.wav")
	player_gunshot.volume = 1.0

func play_sound(sound: DefinedSound) -> void:
	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = sound.sound
	audio_player.volume_db = sound.volume
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(_sound_finished_playing.bind(audio_player))


func _sound_finished_playing(audio_player: AudioStreamPlayer) -> void:
	audio_player.queue_free()
