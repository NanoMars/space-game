extends ProjectileMover

var homing_force: float = 100

var target_enemy: Node2D

func _ready() -> void:
	super._ready()

	var enemies: Array = get_tree().get_nodes_in_group("enemies");
	if not enemies:
		return

	target_enemy = enemies.pick_random()
	if not target_enemy:
		return

	target_enemy.tree_exited.connect(_find_new_enemy)




func _physics_process(delta: float) -> void:
	if not projectile:
		return

	if not target_enemy:
		_find_new_enemy()
		return

	var direction_to_enemy: Vector2 = (projectile.global_position - target_enemy.global_position).normalized()
	projectile.apply_central_force(direction_to_enemy * delta * homing_force)
	print("applied force, ", (direction_to_enemy * delta * homing_force))

func _find_new_enemy() -> void:
	var enemies: Array = get_tree().get_nodes_in_group("enemies");
	if enemies.is_empty():
		target_enemy = null
		return
	
	target_enemy = enemies.pick_random()
	if target_enemy:
		target_enemy.tree_exited.connect(_find_new_enemy)
