extends Node

var last_object_with_focus: Control = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)
	await get_tree().process_frame
	last_object_with_focus = get_viewport().gui_get_focus_owner()
	if last_object_with_focus == null:
		var buttons = get_tree().root.find_children("*", "Button", true, false)
		for button in buttons:
			if button.visible and button.is_visible_in_tree():
				last_object_with_focus = button
				last_object_with_focus.grab_focus()
				break

func _on_gui_focus_changed(new_focus: Control) -> void:
	if new_focus != null:
		last_object_with_focus = new_focus
	elif last_object_with_focus != null and last_object_with_focus.is_inside_tree() and last_object_with_focus.visible and last_object_with_focus.is_visible_in_tree() and new_focus == null:
		last_object_with_focus.grab_focus()
	if new_focus.visible == false:
		grab_first_focusable()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down") or event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		grab_first_focusable()


func grab_first_focusable() -> void:
	if not get_viewport().gui_get_focus_owner():
		var buttons = get_tree().root.find_children("*", "Button", true, false)
		for button in buttons:
			if button.visible and button.is_visible_in_tree():
				last_object_with_focus = button
				last_object_with_focus.grab_focus()
				print("Grabbing focus for ", last_object_with_focus.name)
				break
