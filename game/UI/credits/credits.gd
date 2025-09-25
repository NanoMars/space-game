extends Control

@export_file("*.tscn") var main_menu_scene: String
@export var return_button: Button

func _ready() -> void:
	return_button.grab_focus()
	return_button.pressed.connect(_on_return_pressed)

func _on_return_pressed() -> void:
	SceneManager.change_scene(main_menu_scene, {"transition": "fade"})



func _on_cisco_mouse_exited() -> void:
	MusicPlayer.lowpass_enabled = true

func _on_cisco_mouse_entered() -> void:
	MusicPlayer.lowpass_enabled = false
