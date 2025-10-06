extends RigidBody2D
class_name Enemy
@onready var health: Health = $Health
@export var enemy_name: String = "Enemy"
@export var point_value: int = 100
var dead: bool = false
signal died

@export var shaker_component: ShakerComponent2D
var camera: Camera2D

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

	camera = get_tree().get_first_node_in_group("camera") as Camera2D

func damage(amount: float, from: Node = null) -> void:
	if health and health.has_method("damage"):
		health.damage(amount, from)
		if shaker_component:
			shaker_component.play_shake()
		var cam_shaker: ShakerComponent2D = null
		if camera:
			cam_shaker = camera.find_child("EnemyDamageShake") as ShakerComponent2D
			print("Found camera shaker: ", cam_shaker != null)
		if cam_shaker:
			cam_shaker.play_shake()
			print("Camera shake played from enemy damage")
		

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
