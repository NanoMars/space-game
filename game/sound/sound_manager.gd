extends Node


func play_sound(sound: AudioStreamPlayer) -> void:
	if sound:
		sound.get_parent().remove_child(sound)
		add_child(sound)
		sound.play()
		await sound.finished
		sound.queue_free()

func _ready() -> void:
	Settings.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()

func _on_settings_changed() -> void:
	var sfx_volume = Settings._get("sfx volume")
	var master_volume = Settings._get("master volume")
	var music_volume = Settings._get("music volume")
	
	if sfx_volume != null:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), sfx_volume)
	if master_volume != null:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), master_volume)
	if music_volume != null:
		AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), music_volume)
