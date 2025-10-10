extends Node

signal score_changed(new_score: int)
signal score_multiplier_changed(new_multiplier: float)
signal total_kills_changed(new_total: int)

var player_weapon: WeaponStats

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
enum ActionType {
    Round,
    Upgrade,
    Downgrade
}

var action_types: Array = [
    ActionType.Round,
    ActionType.Upgrade,
    ActionType.Downgrade
]

var enemy_types: Array[EnemyType] = []

var enemies_seen: Array[String] = []
var keybinds_shown: bool = false

func _ready() -> void:
	reset()


func reset() -> void:
	
	concurrent_cap = 3
	score_multiplier = 1.0
	active_modifiers.clear()
	total_kills = 10
	currentRound = 1
	enemy_types.clear()
	var basic_enemy := EnemyType.new()
	basic_enemy.scene = preload("res://game/heatseeking_guy.tscn")
	basic_enemy.weight = 1.0
	enemy_types.append(basic_enemy)
	score = 0
	enemies_seen.clear()
	keybinds_shown = false