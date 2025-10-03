extends RigidBody2D
class_name Enemy
@onready var health: Health = $Health

@export var point_value: int = 100
var dead: bool = false
signal died


func _ready() -> void:
	if health:
		health.died.connect(_on_died)
		health.damaged.connect(_damaged)

func damage(amount: float, from: Node = null) -> void:
	if health and health.has_method("damage"):
		health.damage(amount, from)
		var camera: Camera2D = get_tree().get_first_node_in_group("camera") as CameraWithShake
		camera.shake(amount * 1)

func _on_died(from: Node) -> void:
	if dead:
		return
	died.emit(self)
	dead = true	
	if from != self:
		ScoreManager.score += point_value
	SoundManager.play_sound(SoundManager.enemy_death)
	
	queue_free()

func _damaged(_amount: float, _source: Node) -> void:
	SoundManager.play_sound(SoundManager.damage_sound_2)
