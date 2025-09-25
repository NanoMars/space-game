extends Control

@export_file("*.tscn") var main_menu_scene: String

func _ready() -> void:
	SceneManager.change_scene(main_menu_scene, {"transition": "fade", "wait_time": 0.0})
