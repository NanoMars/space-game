extends Node

@export var lowpass_enabled: bool = false
@export var playing_music: bool = true

func _ready() -> void:
	MusicPlayer.lowpass_enabled = lowpass_enabled
	MusicPlayer.playing_music = playing_music
	
