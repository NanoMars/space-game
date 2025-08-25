extends Node
class_name Health

signal damaged(amount: float, from: Node)
signal died(from: Node)
signal health_changed(new_health: float)

@export var max_health: float = 100.0
var health: float:
	get:
		return _health
	set(value):
		_health = clamp(value, 0.0, max_health)
		emit_signal("health_changed", _health)

var _health: float

func _ready() -> void:
	health = max_health

func damage(amount: float, from: Node = null) -> void:
	if amount <= 0.0:
		return
	health = max(health - amount, 0.0)
	emit_signal("damaged", amount, from)
	if health <= 0.0:
		die(from)

func die(from: Node = null) -> void:
	emit_signal("died", from)
	print("Health died: ", get_parent().name)