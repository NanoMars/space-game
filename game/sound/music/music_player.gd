extends Node

var audio_player: AudioStreamPlayer

var music_volume: float = -10.0
var lowpass_cutoff: float = 700.0

var music_bus: int = 1 # default bus

var playing_music: bool = true
var lowpass_enabled: bool = false

var playing_dynamic_volume: float = 1.0 # 1.0 = full volume, 0.0 = silent
var playing_dynamic_lowpass: float = 0.0 # 0.0 = no lowpass, 1.0 = full lowpass

var playing_volume_target: float = 1.0 # the target we'll smoothly move to
var playing_lowpass_target: float = 0.0 # the target we'll smoothly move to

var volume_change_speed: float = 1.0 # how quickly to change volume in seconds
var lowpass_change_speed: float = 1.0 # how quickly to change lowpass in seconds

func _ready() -> void:
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = preload("res://game/sound/music/TORRENTIAL DEPTHS.wav")
	audio_player.bus = "Music"
	audio_player.process_mode = PROCESS_MODE_ALWAYS
	audio_player.play()
	
	
func _process(delta: float) -> void:
	if playing_music:
		playing_volume_target = 1.0
	else:	
		playing_volume_target = 0.0

	if lowpass_enabled:
		playing_lowpass_target = 1.0
	else:
		playing_lowpass_target = 0.0

	# Smoothly move volume and lowpass towards targets
	if playing_dynamic_volume < playing_volume_target:
		playing_dynamic_volume = min(playing_dynamic_volume + delta / volume_change_speed, playing_volume_target)
	elif playing_dynamic_volume > playing_volume_target:
		playing_dynamic_volume = max(playing_dynamic_volume - delta / volume_change_speed, playing_volume_target)

	if playing_dynamic_lowpass < playing_lowpass_target:
		playing_dynamic_lowpass = min(playing_dynamic_lowpass + delta / lowpass_change_speed, playing_lowpass_target)
	elif playing_dynamic_lowpass > playing_lowpass_target:
		playing_dynamic_lowpass = max(playing_dynamic_lowpass - delta / lowpass_change_speed, playing_lowpass_target)

	# apply volume and lowpass
	audio_player.volume_db = music_volume + linear_to_db(playing_dynamic_volume)
	if playing_dynamic_lowpass > 0.0:
		var cutoff = lerp(22000.0, lowpass_cutoff, playing_dynamic_lowpass)
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, true)
		AudioServer.get_bus_effect(AudioServer.get_bus_index("Music"), 0).set_cutoff(cutoff)
		
	else:
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Music"), 0, false)
