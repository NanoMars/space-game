extends Node

var damage_sound: DefinedSound = DefinedSound.new()
var damage_sound_2: DefinedSound = DefinedSound.new()
var player_gunshot: DefinedSound = DefinedSound.new()
var enemy_death: DefinedSound = DefinedSound.new()
var player_hurt: DefinedSound = DefinedSound.new()

var talk_1: DefinedSound = DefinedSound.new()
var talk_2: DefinedSound = DefinedSound.new()

var bomb_beep: DefinedSound = DefinedSound.new()



func _ready() -> void:
	assign_sounds()

	Settings.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()

func _on_settings_changed() -> void:
	
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), Settings._get("master volume"))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), Settings._get("music volume"))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), Settings._get("sfx volume"))

func assign_sounds() -> void:
	damage_sound.sound = preload("res://game/sound/damage1.ogg")
	damage_sound.volume = 0

	damage_sound_2.sound = preload("res://game/sound/damage2.wav")
	damage_sound_2.volume = -7.5

	player_gunshot.sound = preload("res://game/sound/Gunshot.wav")
	player_gunshot.volume = -20

	enemy_death.sound = preload("res://game/sound/enemydeath.wav")
	enemy_death.volume = -5

	player_hurt.sound = preload("res://game/sound/playerhurt.wav")
	player_hurt.volume = -1

	talk_1.sound = preload("res://game/sound/talk1.wav")
	talk_1.volume = 10

	talk_2.sound = preload("res://game/sound/talk2.wav")
	talk_2.volume = 10

	bomb_beep.sound = preload("res://game/sound/bomb_beep.wav")
	bomb_beep.volume = 0


func play_sound(sound: DefinedSound, bus: String = "SFX") -> void:
	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = sound.sound
	audio_player.volume_db = sound.volume
	audio_player.set_bus(bus)
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(_sound_finished_playing.bind(audio_player))


func _sound_finished_playing(audio_player: AudioStreamPlayer) -> void:
	audio_player.queue_free()
