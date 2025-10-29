extends ProjectileMover

var homing_strength: float = 5.0  # How aggressively it steers (0-10 is good range)
var max_speed: float = 500.0  # Maximum velocity
var target_enemy: Node2D

func _ready() -> void:
	super._ready()
	_find_new_enemy()

func _physics_process(delta: float) -> void:
	if not projectile or not target_enemy:
		return

	if not is_instance_valid(target_enemy):
		_find_new_enemy()
		return

	# Calculate desired direction and velocity
	var direction_to_enemy: Vector2 = (target_enemy.global_position - projectile.global_position).normalized()
	var desired_velocity: Vector2 = direction_to_enemy * max_speed
	
	# Calculate steering force (difference between desired and current velocity)
	var steering: Vector2 = (desired_velocity - projectile.linear_velocity) * homing_strength * delta
	
	# Apply steering
	projectile.linear_velocity += steering
	
	# Clamp to max speed (safety check)
	if projectile.linear_velocity.length() > max_speed:
		projectile.linear_velocity = projectile.linear_velocity.normalized() * max_speed

func _find_new_enemy() -> void:
	# Disconnect previous signal if target exists
	if target_enemy and is_instance_valid(target_enemy):
		target_enemy.tree_exited.disconnect(_find_new_enemy)
	
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		target_enemy = null
		return
	
	target_enemy = enemies.pick_random()
	if target_enemy:
		target_enemy.tree_exited.connect(_find_new_enemy, CONNECT_ONE_SHOT)
