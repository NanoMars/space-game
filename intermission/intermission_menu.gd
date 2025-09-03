extends Control

@export var mod_list: VBoxContainer
@export var decision_list: VBoxContainer

@export var tween_time: float = 0.5

func _on_continue_pressed() -> void:
	# Fade out decision list and fade in mod list in parallel.
	if mod_list:
		mod_list.show()
	if decision_list and decision_list.material:
		var t_out := create_tween()
		t_out.tween_property(decision_list.material, "shader_parameter/opacity", 0.0, tween_time)
		t_out.tween_callback(Callable(decision_list, "hide"))
	if mod_list and mod_list.material:
		var t_in := create_tween()
		t_in.tween_property(mod_list.material, "shader_parameter/opacity", 1.0, tween_time)

func _ready() -> void:
	# Start with mod list hidden and decision list faded in.
	if mod_list:
		mod_list.hide()
		if mod_list.material:
			mod_list.material.set_shader_parameter("opacity", 0.0)
	if decision_list:
		decision_list.show()
		if decision_list.material:
			decision_list.material.set_shader_parameter("opacity", 0.0)
			var t := create_tween()
			t.tween_property(decision_list.material, "shader_parameter/opacity", 1.0, tween_time)
