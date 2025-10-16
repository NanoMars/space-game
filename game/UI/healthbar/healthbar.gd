@tool
extends Panel

var history: Array[float] = []

@export var delay_sec: float = 1
@export var delay_resolution: int = 10
@export var timer: Timer

var delay_internal_sec: float:
	get:
		return delay_sec / delay_resolution
		
func _init() -> void:
	if not timer:
		timer = Timer.new()
		add_child(timer)
