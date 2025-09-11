extends Node

signal score_changed(new_score: int)
signal score_multiplier_changed(new_multiplier: float)
signal total_kills_changed(new_total: int)

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

var enemy_types: Array[EnemyType] = []

func _ready() -> void:
	score = 0
	var basic_enemy := EnemyType.new()
	basic_enemy.scene = preload("res://game/heatseeking_guy.tscn")
	basic_enemy.weight = 1.0
	enemy_types.append(basic_enemy)
