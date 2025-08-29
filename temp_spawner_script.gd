extends Marker3D

@export var enemy_to_spawn: PackedScene
@export var velocity_variance: float = 100.0

func _spawn_enemy() -> void:

	var enemy_instance = enemy_to_spawn.instantiate()
	var parent := get_parent()
	parent.add_child(enemy_instance)
	# Set position *after* adding to the tree so the transform is valid
	enemy_instance.global_transform = global_transform
	enemy_instance.linear_velocity.x = randf_range(-velocity_variance, velocity_variance)
