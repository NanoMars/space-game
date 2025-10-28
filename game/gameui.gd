extends Control

@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var player_health: Health = player.get_node("Health") if is_instance_valid(player) else null
@onready var spawner: Spawner = get_tree().get_first_node_in_group("spawner")
@onready var health_bar: Panel = $HealthBar
@onready var score_label: Label = $ScoreLabel
@onready var multiplier_label: Label = $MultiplierLabel
@onready var enemy_count_label: Label = $EnemyCountLabel
@onready var round_label: Label = $RoundLabel
@onready var super_progress_bar: ProgressBar = $SuperProgressBar
@onready var super_ready: Control = $SuperReady
# Cache vignette material
@onready var vignette_mat: ShaderMaterial = $Vignette.material
@onready var super_flame: ColorRect = $SuperFlame

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
@export var super_interpolate: Curve
@export var super_fire_interpolate: Curve
var super_fire_max_radius: float = 2.0
var super_fire_min_radius: float = 1.385
var super_fire_hidden_radius: float = 0.0


# Baselines and rotation offset
var _base_power_px: float = 0.0
var _base_angle_deg: float = 0.0
var _rot_angle_offset: float = 0.0

func _ready() -> void:
	_ensure_references()
	_connect_signals()

	# Cache base shader values
	if vignette_mat:
		_base_power_px = vignette_mat.get_shader_parameter("power_px")
		_base_angle_deg = vignette_mat.get_shader_parameter("angle_deg")
		vignette_mat.set_shader_parameter("power_px", _base_power_px)
		vignette_mat.set_shader_parameter("angle_deg", _base_angle_deg)

	var reset_callable := Callable(self, "_on_reset_spawner")
	if not ScoreManager.reset_spawner.is_connected(reset_callable):
		ScoreManager.reset_spawner.connect(reset_callable)
	if not ScoreManager.super_ready_changed.is_connected(_on_super_ready_changed):
		ScoreManager.super_ready_changed.connect(_on_super_ready_changed)
	super_ready.visible = ScoreManager.super_ready
	_on_reset_spawner()

func _on_super_ready_changed(new_ready: bool) -> void:
	super_ready.visible = new_ready

func _on_reset_spawner() -> void:
	_ensure_spawner()
	_connect_signals()
	round_label.visible = true
	round_label.modulate.a = 1.0
	round_label.text = "Round " + str(ScoreManager.currentRound)
	var tween: Tween = create_tween()
	tween.tween_property(round_label, "modulate:a", 0.0, 0.5).set_delay(2.0)
	await tween.finished
	round_label.visible = false
	if is_instance_valid(spawner):
		_enemy_count_changed(spawner._enemies_left)

func _on_health_changed(new_health: float) -> void:
	health_bar.value = new_health / player_health.max_health
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

func _connect_signals() -> void:
	_ensure_references()

	var score_callable := Callable(self, "_on_score_changed")
	if not ScoreManager.score_changed.is_connected(score_callable):
		ScoreManager.score_changed.connect(score_callable)
		_on_score_changed(ScoreManager.score)

	var multiplier_callable := Callable(self, "_on_score_multiplier_changed")
	if not ScoreManager.score_multiplier_changed.is_connected(multiplier_callable):
		ScoreManager.score_multiplier_changed.connect(multiplier_callable)
		_on_score_multiplier_changed(ScoreManager.score_multiplier)

	if is_instance_valid(player_health):
		var health_callable := Callable(self, "_on_health_changed")
		if not player_health.health_changed.is_connected(health_callable):
			player_health.health_changed.connect(health_callable)
		health_bar.value = player_health.health / player_health.max_health
		old_health = player_health.health
	else:
		health_bar.value = 0.0

	if is_instance_valid(spawner):
		var enemy_callable := Callable(self, "_enemy_count_changed")
		if not spawner.enemies_left.is_connected(enemy_callable):
			spawner.enemies_left.connect(enemy_callable)
		_enemy_count_changed(spawner._enemies_left)
	else:
		enemy_count_label.text = "--"

func _ensure_references() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player) and not is_instance_valid(player_health):
		player_health = player.get_node("Health")
	if not is_instance_valid(spawner):
		spawner = get_tree().get_first_node_in_group("spawner")

func _ensure_spawner() -> void:
	if not is_instance_valid(spawner):
		spawner = get_tree().get_first_node_in_group("spawner")

func _process(delta: float) -> void:
	_connect_signals()
	# Decay rotation speed, integrate angle, then set absolute angle
	if vignette_rot_speed > 0.0:
		vignette_rot_speed = max(vignette_rot_speed - vignette_rot_decay * delta, 0.0)
	_rot_angle_offset += vignette_rot_speed * delta
	if vignette_mat:
		vignette_mat.set_shader_parameter("angle_deg", _base_angle_deg + _rot_angle_offset)
	var super_interpolated_progress = super_interpolate.sample(ScoreManager.super_progress)
	super_progress_bar.value = super_interpolated_progress * (super_progress_bar.max_value - super_progress_bar.min_value) + super_progress_bar.min_value

	# Decay intensity back to base, then set absolute power (no accumulation)
	if vignette_scale > 0.0:
		vignette_scale = max(vignette_scale - vignette_scale_decay * delta, 0.0)
	if vignette_mat:
		vignette_mat.set_shader_parameter("power_px", _base_power_px + vignette_scale)

	if Engine.time_scale < 1.0:
		Engine.time_scale = lerp(Engine.time_scale, 1.0, delta * 2)
	
	

	

	
