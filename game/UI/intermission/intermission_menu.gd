extends Control

@export var mod_list: VBoxContainer
@export var main_scene: PackedScene

@export var tween_time: float = 0.5

@export var score_label: Label

func _ready() -> void:
	MusicPlayer.lowpass_enabled = true
	MusicPlayer.playing_music = true
	score_label.text = "End here to score " + str(ScoreManager.score) + ""
	for child in mod_list.get_children():
		if child.get_class() == "Button":
			child.pressed.connect(_on_mod_button_pressed.bind(child))
	
	# Show mod list immediately with fade-in animation
	if mod_list:
		if mod_list.material:
			mod_list.material.set_shader_parameter("opacity", 0.0)
		mod_list.show()
		if mod_list.material:
			var t := create_tween()
			t.tween_property(mod_list.material, "shader_parameter/opacity", 1.0, tween_time)
	
	if mod_list.get_child_count() > 0:
		mod_list.get_children()[0].grab_focus()
	
func _on_mod_button_pressed(_button: Button) -> void:
	ScoreManager.next_round()
	SceneManager.change_scene("res://main_scene.tscn", {"transition": "fade"})
