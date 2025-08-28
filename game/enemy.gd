extends RigidBody3D
class_name Enemy
@onready var health: Health = $Health

@export var point_value: int = 100
var dead: bool = false

func _ready() -> void:
	if health:
		health.died.connect(_on_died)
		health.damaged.connect(_damaged)

func damage(amount: float, from: Node = null) -> void:
	if health and health.has_method("damage"):
		health.damage(amount, from)

func _on_died(_from: Node) -> void:
	if dead:
		return
	dead = true
	SoundManager.play_sound(SoundManager.enemy_death)
	ScoreManager.score += point_value
	print("dead")
	queue_free()

func _damaged(_amount: float, _source: Node) -> void:
	SoundManager.play_sound(SoundManager.damage_sound_2)