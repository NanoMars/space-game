extends Control

@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var player_health: Health = player.get_node("Health")
@onready var spawner: Spawner = get_tree().get_first_node_in_group("spawner")
@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel
@onready var multiplier_label: Label = $MultiplierLabel
@onready var enemy_count_label: Label = $EnemyCountLabel
@onready var round_label: Label = $RoundLabel
# Cache vignette material
@onready var vignette_mat: ShaderMaterial = $Vignette.material

var old_health: float = 100.0
var vignette_rot_speed: float = 0.0
@export var vignette_max_rot_speed: float = 5.0
@export var vignette_rot_decay: float = 1.0
@export var vignette_rot_speed_per_health_lost: float = 5.0

# Start at 0 so it’s invisible until damage
var vignette_scale: float = 0.0
@export var vignette_max_scale: float = 10
@export var vignette_scale_decay: float = 5.0
@export var vignette_scale_per_health_lost: float = 5.0

@export var camera_shake: ShakerComponent2D

# Baselines and rotation offset
var _base_power_px: float = 0.0
var _base_angle_deg: float = 0.0
var _rot_angle_offset: float = 0.0

func _ready() -> void:
	player_health.health_changed.connect(_on_health_changed)
	health_bar.value = player_health.health / player_health.max_health * health_bar.max_value
	spawner.enemies_left.connect(_enemy_count_changed)

	ScoreManager.score_changed.connect(_on_score_changed)
	score_label.text = str(ScoreManager.score)

	ScoreManager.score_multiplier_changed.connect(_on_score_multiplier_changed)
	multiplier_label.text = "X" + str(ScoreManager.score_multiplier)

	enemy_count_label.text = str(spawner._enemies_left) + " left"
	old_health = player_health.health

	# Cache base shader values
	if vignette_mat:
		_base_power_px = vignette_mat.get_shader_parameter("power_px")
		_base_angle_deg = vignette_mat.get_shader_parameter("angle_deg")
		vignette_mat.set_shader_parameter("power_px", _base_power_px)
		vignette_mat.set_shader_parameter("angle_deg", _base_angle_deg)

	ScoreManager.reset_spawner.connect(_on_reset_spawner)
	_on_reset_spawner()

func _on_reset_spawner() -> void:
	round_label.visible = true
	round_label.modulate.a = 1.0
	round_label.text = "Round " + str(ScoreManager.currentRound)
	var tween: Tween = create_tween()
	tween.tween_property(round_label, "modulate:a", 0.0, 0.5).set_delay(2.0)
	await tween.finished
	round_label.visible = false
	_enemy_count_changed(spawner._enemies_left)

func _on_health_changed(new_health: float) -> void:
	health_bar.value = new_health / player_health.max_health * health_bar.max_value
	if new_health < old_health:
		var health_lost = old_health - new_health
		vignette_rot_speed = clamp(vignette_rot_speed + health_lost * vignette_rot_speed_per_health_lost, 0.0, vignette_max_rot_speed)
		vignette_scale = clamp(vignette_scale + health_lost * vignette_scale_per_health_lost, 0.0, vignette_max_scale)
		Engine.time_scale -= health_lost / 100.0
		if camera_shake:
			camera_shake.play_shake()
	old_health = new_health

func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)

func _on_score_multiplier_changed(new_multiplier: float) -> void:
	multiplier_label.text = "X" + str(new_multiplier)

func _enemy_count_changed(new_count: int) -> void:
	enemy_count_label.text = str(new_count) + " left"

func _process(delta: float) -> void:
	# Decay rotation speed, integrate angle, then set absolute angle
	if vignette_rot_speed > 0.0:
		vignette_rot_speed = max(vignette_rot_speed - vignette_rot_decay * delta, 0.0)
	_rot_angle_offset += vignette_rot_speed * delta
	if vignette_mat:
		vignette_mat.set_shader_parameter("angle_deg", _base_angle_deg + _rot_angle_offset)

	# Decay intensity back to base, then set absolute power (no accumulation)
	if vignette_scale > 0.0:
		vignette_scale = max(vignette_scale - vignette_scale_decay * delta, 0.0)
	if vignette_mat:
		vignette_mat.set_shader_parameter("power_px", _base_power_px + vignette_scale)

	if Engine.time_scale < 1.0:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, delta * 2)
