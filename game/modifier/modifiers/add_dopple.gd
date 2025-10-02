extends Modifier
class_name AddDopple

@export var doppleganger_scene: PackedScene
@export var spawn_position: Vector2 = Vector2(0, 9)

# lifecycle hooks. override only what you need.
func on_run_start(game_root: Node2D) -> void:
	if not doppleganger_scene:
		return
	var dopple_instance := doppleganger_scene.instantiate()
	if dopple_instance is Node2D:
		(dopple_instance as Node2D).global_position = spawn_position
	game_root.add_child(dopple_instance)

func on_enemy_spawn(enemy: Node) -> void: pass
func on_enemy_death(transform: Transform2D) -> void: pass

# number modifiers. chain these across active modifiers.
func modify_spawn_count(base: int) -> int: return base
func modify_spawn_rate(base: float) -> float: return base
func modify_enemy_health(base: float) -> float: return base
func modify_enemy_speed(base: float) -> float: return base
