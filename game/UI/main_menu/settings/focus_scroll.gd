extends ScrollContainer

func _process(delta: float) -> void:
	var focused_control: Control = get_viewport().gui_get_focus_owner()
	if focused_control == null:
		return
	var screen_center: Vector2 = get_viewport_rect().size / 2
	var ydiff: float = focused_control.get_global_position().y + focused_control.size.y / 2 - screen_center.y
	self.scroll_vertical += ydiff * 0.1
	print("Focused control: ", focused_control.name, " ydiff: ", ydiff, " scroll_vertical: ", self.scroll_vertical)
