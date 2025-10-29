extends ProjectileMover

var homing_force: float = 10000
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

	var direction_to_enemy: Vector2 = (target_enemy.global_position - projectile.global_position).normalized()
	projectile.linear_velocity += direction_to_enemy * homing_force * delta

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