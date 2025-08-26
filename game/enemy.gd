extends RigidBody3D
class_name Enemy
@onready var health: Health = $Health

@export var point_value: int = 100

func _ready() -> void:
	if health:
		health.died.connect(_on_died)

func damage(amount: float, from: Node = null) -> void:
	if health and health.has_method("damage"):
		health.damage(amount, from)

func _on_died(from: Node) -> void:
	queue_free()
