extends Control
@export_file("*.tscn") var game_scene: String
@export_file("*.tscn") var settings_scene: String
@export_file("*.tscn") var credits_scene: String

func _on_start_pressed() -> void:
	SceneManager.change_scene(game_scene, {"transition": "fade"})
