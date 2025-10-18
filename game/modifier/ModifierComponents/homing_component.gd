extends Node2D
class_name HomingComponent

@export var homing_strength_per_level: float = 100.0

var homing_level: int = 1
var projectile: Projectile = null

func _ready() -> void:
	# Get reference to parent projectile
	if get_parent() is Projectile:
		projectile = get_parent() as Projectile
	else:
		push_error("HomingComponent must be a child of a Projectile")
		queue_free()
		return
	
	# Check for homing modifier stacks
	# for modifier in ScoreManager.active_modifiers:
	# 	if modifier.display_name == "homing bullets":
	# 		homing_level = modifier.stacks
	# 		break
	process_priority = 10
	

func _physics_process(_delta: float) -> void:
	if not projectile or homing_level <= 0 or projectile.enemy_projectile:
		return
	
	# Find nearest enemy
	var nearest_enemy: Node2D = null
	var nearest_dist: float = 1e10
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy and enemy is Node2D:
			var dist: float = enemy.global_position.distance_to(projectile.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_enemy = enemy
	
	if not nearest_enemy:
		return
	
	print("Homing towards enemy at distance: ", nearest_dist)
	# Apply homing behavior
	var to_enemy: Vector2 = (nearest_enemy.global_position - projectile.global_position).normalized()
	var velocity_length: float = projectile.linear_velocity.length()
	var current_speed: float = velocity_length
	
	if current_speed <= 0.0001:
		current_speed = projectile.weapon_stats.projectile_speed if projectile.weapon_stats else homing_strength_per_level
	
	var current_dir: Vector2 = projectile.linear_velocity.normalized() if velocity_length > 0.0001 else to_enemy
	var angle_diff: float = current_dir.angle_to(to_enemy)
	var max_turn: float = homing_strength_per_level * homing_level * _delta / max(current_speed, 0.0001)
	var clamped_turn: float = clamp(angle_diff, -max_turn, max_turn)
	var new_dir: Vector2 = current_dir.rotated(clamped_turn).normalized()
	print("changing velocity to ", new_dir * current_speed)
	await get_tree().process_frame
	projectile.linear_velocity = new_dir * current_speed
	print("New projectile velocity: ", projectile.linear_velocity)