extends Node

func _ready() -> void:
	var spawner = get_tree().get_first_node_in_group("spawner") as Spawner
	if spawner:
		spawner.enemy_died.connect(_on_enemy_died)
		spawner.enemy_spawned.connect(_on_enemy_spawned)
	

func _on_enemy_died(transform: Transform3D) -> void:
	for mod in ScoreManager.active_modifiers:
		mod.on_enemy_death(transform)

func _on_enemy_spawned(enemy: Node) -> void:
	for mod in ScoreManager.active_modifiers:
		mod.on_enemy_spawn(enemy)
