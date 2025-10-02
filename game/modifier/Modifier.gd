extends Resource
class_name Modifier

@export var display_name: String = "" # for UI, e.g. "Fast Entities"
@export var stackable: bool = true
@export var max_stacks: int = 5
@export var score_multiplier: float = 0.5 # added to base 1.0
@export var enemy_to_spawn: EnemyType = null
var stacks: int = 1

# lifecycle hooks. override only what you need.
func on_run_start(game_root: Node2D) -> void: pass
func on_enemy_spawn(enemy: Node) -> void: pass
func on_enemy_death(transform: Transform2D) -> void: pass

# number modifiers. chain these across active modifiers.
func modify_spawn_count(base: int) -> int: return base
func modify_spawn_rate(base: float) -> float: return base
func modify_enemy_speed(base: float) -> float: return base
func modify_enemy_health(base: float) -> float: return base