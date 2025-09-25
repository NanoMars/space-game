extends Control
@export_file("*.tscn") var game_scene: String
@export_file("*.tscn") var settings_scene: String
@export_file("*.tscn") var credits_scene: String

@export var default_focus: Control

func _on_start_pressed() -> void:
	SceneManager.change_scene(game_scene, {"transition": "fade"})

func _ready() -> void:
	if default_focus:
		default_focus.grab_focus()

func _on_settings_pressed() -> void:
	SceneManager.change_scene(settings_scene, {"transition": "fade"})


func _on_credits_pressed() -> void:
	SceneManager.change_scene(credits_scene, {"transition": "fade"})
