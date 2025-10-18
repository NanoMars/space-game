extends Node

var frozen: bool:
	get:
		return freeze_count > 0

var freeze_count: int = 0

func freeze_short() -> void:
	freeze_count += 1
	update_freeze_state()
	await get_tree().create_timer(0.02, true).timeout
	freeze_count -= 1
	update_freeze_state()

func freeze_long() -> void:
	freeze_count += 1
	update_freeze_state()
	await get_tree().create_timer(0.04, true).timeout
	freeze_count -= 1
	update_freeze_state()

func update_freeze_state() -> void:
	if frozen:
		get_tree().paused = true
	else:
		get_tree().paused = false