extends Node2D

@export var goal_node: Node2D = null
@export var return_speed: float = 5.0
@export var distance_from_goal: float = 20.0
@export var edge_buffer: Vector2 = Vector2(64.0, 32.0)

func _ready() -> void:
	top_level = true
	if goal_node == null:
		goal_node = get_parent() as Node2D

func _physics_process(delta: float) -> void:
	if goal_node == null:
		return
	var goal_position: Vector2 = goal_node.global_position + get_goal_offset()
	var diff: Vector2 = goal_position - global_position
	global_position += diff * delta * return_speed

func get_goal_offset() -> Vector2:
	var x := goal_node.global_position.x
	var y := goal_node.global_position.y
	var goal_vector := Vector2(1.0, 0.0)
	var visible_rect: Vector2 = get_viewport().get_visible_rect().size - edge_buffer
	
	if x >= visible_rect.x:
		goal_vector.x = -1.0
	elif x <= edge_buffer.x:
		goal_vector.x = 1.0

	if y >= visible_rect.y:
		goal_vector.y = -1.0
	elif y <= edge_buffer.y:
		goal_vector.y = 1.0

	return goal_vector.normalized() * distance_from_goal
