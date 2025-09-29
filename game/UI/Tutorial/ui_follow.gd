extends Node3D

@export var goal_node: Node3D = get_parent()
@export var return_speed: float = 5.0
@export var distance_from_goal: float = 2.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.top_level = true

func _physics_process(delta: float) -> void:
	var goal_position: Vector3 = Vector3(get_goal_position().x, 0, get_goal_position().y) + goal_node.global_position
	var diff = goal_position - global_position

	global_position += diff * delta * return_speed

func get_goal_position() -> Vector2:
	
	var x = goal_node.global_position.x
	var z = goal_node.global_position.z
	var goal_vector: Vector2 = Vector2(1, 0)
	
	if x >= 5.5:
		goal_vector.x = -1.0
	elif x <= -5.5:
		goal_vector.x = 1.0

	if z >= 2.3:
		goal_vector.y = -1.0
	elif z <= -2.3:
		goal_vector.y = 1.0
	return goal_vector.normalized() * distance_from_goal
