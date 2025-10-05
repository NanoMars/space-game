extends RigidBody2D
class_name Enemy
@onready var health: Health = $Health
@export var enemy_name: String = "Enemy"
@export var point_value: int = 100
var dead: bool = false
signal died

@export var shaker_component: ShakerComponent2D

var enemy_name_display_path: String = "res://game/enemies/enemy_name_display/EnemyNameDisplay.tscn"


func _ready() -> void:
	if health:
		health.died.connect(_on_died)
		health.damaged.connect(_damaged)
	if Settings.get("tutorial enabled") == true and not ScoreManager.enemies_seen.has(enemy_name):
		ScoreManager.enemies_seen.append(enemy_name)
		var enemy_name_display_scene: PackedScene = load(enemy_name_display_path)
		var enemy_name_display: Node2D = enemy_name_display_scene.instantiate()
		enemy_name_display.enemy_name = enemy_name
		enemy_name_display.goal_node = self
		add_child(enemy_name_display)
		enemy_name_display.global_position = global_position

func damage(amount: float, from: Node = null) -> void:
	if health and health.has_method("damage"):
		health.damage(amount, from)
		if shaker_component:
			shaker_component.play_shake()

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
