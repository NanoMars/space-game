extends Node

signal score_changed(new_score: int)
signal score_multiplier_changed(new_multiplier: float)
signal total_kills_changed(new_total: int)

var player_weapon: WeaponStats

var downgrade_scene: PackedScene = preload("res://game/UI/intermission/downgrade/downgrade_screen.tscn")
var upgrade_scene: PackedScene = preload("res://game/UI/intermission/upgrade/upgrade_screen.tscn")
var game_scene: PackedScene = preload("res://main_scene.tscn")

var score: int:
	set(value):
		if value != _score:
			var difference = value - _score
			_score = _score + (difference * score_multiplier)
			emit_signal("score_changed", _score)
	get:
		return int(_score)
var _score: float = 0

var score_multiplier: float:
	set(value):
		if value != _score_multiplier:
			_score_multiplier = value
			emit_signal("score_multiplier_changed", _score_multiplier)
	get:
		return _score_multiplier
var _score_multiplier: float = 1.0

var active_modifiers: Array[Modifier] = []
var total_kills: int:
	get:
		return _total_kills
	set(value):
		_total_kills = value
		emit_signal("total_kills_changed", _total_kills)
var _total_kills: int = 10
var concurrent_cap: int = 3

var currentRound: int = 1
var last_downgrade: bool = true

enum round_types {
	Round,
	#Upgrade,
	Downgrade
}

var current_round_type: int = round_types.Round

var rounds: Array = [
]
signal on_round_complete()

var min_rounds_before_intermission: int = 1
var max_rounds_before_intermission: int = 2

var rounds_since_intermission: int = 0
var previous_rounds: Array = []



var always_have_x_rounds: int = 4

signal reset_spawner()

var enemy_types: Array[EnemyType] = []

var enemies_seen: Array[String] = []
var keybinds_shown: bool = false

func _ready() -> void:
	reset()
	


func reset() -> void:
	
	concurrent_cap = 50
	score_multiplier = 1.0
	active_modifiers.clear()
	total_kills = 100
	currentRound = 1
	enemy_types.clear()
	var basic_enemy := EnemyType.new()
	basic_enemy.scene = preload("res://game/heatseeking_guy.tscn")
	basic_enemy.weight = 1.0
	enemy_types.append(basic_enemy)
	score = 0
	enemies_seen.clear()
	keybinds_shown = false
	current_round_type = round_types.Round
	previous_rounds.clear()
	rounds.clear()
	last_downgrade = true
	
	while rounds.size() < always_have_x_rounds:
		generate_rounds()
	previous_rounds.append(rounds.pop_front())
	print("rounds: ", rounds)

func next_round() -> void:
	var nr = rounds.pop_front()
	previous_rounds.append(nr)

	while rounds.size() < always_have_x_rounds:
		generate_rounds()
	
	match nr:
		round_types.Round:

			print("roundtype is round")
			print("nr: ", nr)
			print("currentRound_type: ", current_round_type)
			currentRound += 1
			rounds_since_intermission += 1
			if nr == round_types.Round:
				reset_spawner.emit()
				print("emitted reset spawner")
			else:
				SceneManager.change_scene(game_scene)

		# round_types.Upgrade:
		# 	print("roundtype is upgrade")
		# 	SceneManager.change_scene(upgrade_scene)
		# 	rounds_since_intermission = 0
		round_types.Downgrade:
			print("roundtype is downgrade")
			SceneManager.change_scene(downgrade_scene)
			rounds_since_intermission = 0

	current_round_type = nr
	on_round_complete.emit()
	print("rounds: ", rounds)
	

func generate_rounds() -> void:
	var round_count: int = int(randi_range(min_rounds_before_intermission, max_rounds_before_intermission))
	for i in range(round_count):
		rounds.append(round_types.Round)

	rounds.append(round_types.Downgrade)
