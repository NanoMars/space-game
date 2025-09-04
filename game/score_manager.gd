extends Node

signal score_changed(new_score: int)
signal score_multiplier_changed(new_multiplier: float)

var score: int:
	set(value):
		if value != _score:
			_score = value
			emit_signal("score_changed", _score * score_multiplier)
	get:
		return _score * score_multiplier
var _score: int = 0

var score_multiplier: float:
	set(value):
		if value != _score_multiplier:
			_score_multiplier = value
			emit_signal("score_multiplier_changed", _score_multiplier)
	get:
		return _score_multiplier
var _score_multiplier: float = 1.0