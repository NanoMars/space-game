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
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), Settings._get("sfx volume"))
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), Settings._get("master volume"))