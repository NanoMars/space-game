extends Modifier
class_name AddDopple

@export var doppleganger_scene: PackedScene

# lifecycle hooks. override only what you need.
func on_run_start(game_root: Node3D) -> void:
	var dopple_instance = doppleganger_scene.instantiate()
	dopple_instance.global_position = Vector3(0, 0, 9)
	game_root.add_child(dopple_instance)

func on_enemy_spawn(enemy: Node) -> void: pass
func on_enemy_death(transform: Transform3D) -> void: pass

# number modifiers. chain these across active modifiers.
func modify_spawn_count(base: int) -> int: return base
func modify_spawn_rate(base: float) -> float: return base
func modify_enemy_health(base: float) -> float: return base
func modify_enemy_speed(base: float) -> float: return base