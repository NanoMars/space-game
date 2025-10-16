@tool
extends Panel

var history: Array[float] = []

@export var value: float:
	get:
		if health_bar and health_bar_sibling:
			return health_bar.size_flags_stretch_ratio
		return 0.0
	set(v):
		if health_bar and health_bar_sibling:
			health_bar.size_flags_stretch_ratio = v
			health_bar_sibling.size_flags_stretch_ratio = 1 - v

@export var delay_sec: float = 1
@export var delay_resolution: int = 10
var timer: float

@export_group("objects")
@export var health_bar: Panel
@export var health_bar_sibling: Control
@export var delayed_health_bar: Panel
@export var delayed_health_bar_sibling: Control

var delay_internal_sec: float:
	get:
		return delay_sec / delay_resolution

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		process_mode = Node.PROCESS_MODE_ALWAYS
		set_process(true)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		# Ensure required nodes exist before using them
		if not (health_bar and health_bar_sibling and delayed_health_bar and delayed_health_bar_sibling):
			return

	if timer + delta >= delay_internal_sec:
		timer = 0
		history.append(value)
		if history.size() > delay_resolution:
			var temp_value = history.pop_front()
			var sib_temp_value = 1 - temp_value
			var tween = get_tree().create_tween()
			var sib_tween = get_tree().create_tween()
			tween.tween_property(delayed_health_bar, "size_flags_stretch_ratio", temp_value, delay_internal_sec)
			sib_tween.tween_property(delayed_health_bar_sibling, "size_flags_stretch_ratio", sib_temp_value, delay_internal_sec)
	else:
		timer += delta
