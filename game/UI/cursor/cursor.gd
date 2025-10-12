extends Node

var cursor_scene: PackedScene = preload("res://game/UI/cursor/cursor.tscn")
var overlay_scene: PackedScene = preload("res://game/UI/filter_overlay.tscn")
var cursor_instance: CanvasLayer
var panel_instance: Panel

var cursor_speed: float = 15

var visibility_transition_time: float = 0.2

var is_visible: bool:
	get:
		return _is_visible
	set(value):
		_is_visible = value
var _is_visible: bool = true

var enabled: bool = true


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor_instance = cursor_scene.instantiate()
	add_child(cursor_instance)
	panel_instance = cursor_instance.get_node("Panel") as Panel
	Settings.settings_changed.connect(_on_settings_changed)
	_on_settings_changed()
	var overlay_instance: CanvasLayer = overlay_scene.instantiate()
	add_child(overlay_instance)

func _on_settings_changed() -> void:
	enabled = Settings.get("custom cursor")

func _process(delta: float) -> void:
	if is_visible:
		panel_instance.modulate.a = lerp(panel_instance.modulate.a, 1.0, delta / visibility_transition_time)
	else:
		panel_instance.modulate.a = lerp(panel_instance.modulate.a, 0.0, delta / visibility_transition_time)

	if not enabled:
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if is_visible:
			is_visible = false
		return
	else:
		if not is_visible:
			is_visible = true
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var diff = mouse_pos - cursor_instance.offset
	cursor_instance.offset += diff * cursor_speed * delta

	if Input.mouse_mode != Input.MOUSE_MODE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	
