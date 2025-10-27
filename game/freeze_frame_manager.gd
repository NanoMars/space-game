extends Node

var frozen: bool:
	get:
		return freeze_time_remaining > 0

var freeze_time_remaining: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(delta: float) -> void:
	if freeze_time_remaining > 0:
		freeze_time_remaining -= delta
		if freeze_time_remaining <= 0:
			freeze_time_remaining = 0
			update_freeze_state()

func freeze_short() -> void:
	freeze_time_remaining += 0.04
	update_freeze_state()

func freeze_long() -> void:
	freeze_time_remaining += 0.15
	update_freeze_state()

func update_freeze_state() -> void:
	if frozen:
		await get_tree().process_frame
		get_tree().paused = true
		get_tree().get_first_node_in_group("invert_rect").visible = true
	else:
		await get_tree().process_frame
		get_tree().paused = false
		get_tree().get_first_node_in_group("invert_rect").visible = false
