extends Node

signal score_changed(new_score: int)

var score: int:
	set(value):
		if value != _score:
			_score = value
			emit_signal("score_changed", _score * score_multiplier)
	get:
		return _score * score_multiplier
var _score: int = 0

var score_multiplier: float = 1.0