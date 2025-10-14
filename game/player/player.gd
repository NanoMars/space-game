extends CharacterBody2D

@export var move_speed: float = 5.0
var normal_move_speed: float
@export var shooting_move_speed: float = 2.5

@onready var health: Health = $Health
@onready var weapon: Weapon = $Weapon

@export var tilt_angle_deg: Vector2 = Vector2(10.0, 5.0)
@export var tilt_speed: float = 5.0
@export var tilt_object: Node3D

@export var jetstream_nodes: Array[Marker2D]

var weapon_stats: WeaponStats:
	set(value):
		if weapon:
			weapon.weapon_stats = value
		_weapon_stats = value
	get:
		return _weapon_stats

var _weapon_stats: WeaponStats = null

# Use a 2D camera in the "camera" group
@onready var cam: Camera2D = get_tree().get_first_node_in_group("camera") as Camera2D

@export var shiny_thing_scene: PackedScene
@export var shaker_component: ShakerComponent3D

var dead: bool = false
signal died(from: Node)

func _ready() -> void:
	if health:
		health.died.connect(_on_died)
	weapon_stats = ScoreManager.player_weapon
	weapon.weapon_stats = weapon_stats
	normal_move_speed = move_speed / 60
	
	ScoreManager.on_round_complete.connect(_on_round_complete)
func _on_round_complete() -> void:
	for modifier in ScoreManager.active_modifiers:
		if modifier.display_name == "heal between rounds":
			if health:
				health.health += health.max_health / 3

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2(
		Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	)
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var current_move_speed = move_speed if weapon.can_shoot == true else shooting_move_speed

	velocity.x = -input_vector.x * current_move_speed * delta
	velocity.y = -input_vector.y * current_move_speed * delta

	move_and_slide()

	# Clamp within the camera's visible world rect
	var visible_world := get_camera_visible_world_rect()
	var pos := global_position
	pos.x = clamp(pos.x, visible_world.position.x, visible_world.position.x + visible_world.size.x)
	pos.y = clamp(pos.y, visible_world.position.y, visible_world.position.y + visible_world.size.y)
	global_position = pos

	# Poll "shoot" action from Input Map
	var shoot_pressed := Input.is_action_pressed("shoot") 
	if weapon:
		weapon.firing = shoot_pressed
	
	# Handle tilt based on movement
	var target_tilt: Vector2 = (velocity / normal_move_speed) * tilt_angle_deg
	tilt_object.rotation_degrees = lerp(tilt_object.rotation_degrees, Vector3(target_tilt.y, 180, -target_tilt.x), tilt_speed * delta)

	for node in jetstream_nodes:
		if node:
			node.active = velocity.y < 0


func get_camera_visible_world_rect() -> Rect2:
	# Uses Camera2D center and zoom to compute the world-space rect that is currently on screen.
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	if cam:
		var center_world: Vector2 = cam.get_screen_center_position()
		var half_world: Vector2 = (vp_size * 0.5) * cam.zoom
		return Rect2(center_world - half_world, half_world * 2.0)
	# Fallback (no Camera2D found): assume 1:1 canvas transform
	return Rect2(Vector2.ZERO, vp_size)

func _on_died(_from: Node) -> void:
	if dead:
		return
	
	dead = true
	$PlayerSprite.visible = false
	self.move_speed = 0.0
	self.velocity = Vector2.ZERO
	var shiny_thing_instance = shiny_thing_scene.instantiate()
	shiny_thing_instance.global_position = self.global_position
	get_parent().add_child(shiny_thing_instance)
	queue_free()

func damage(amount: float, from: Node = null) -> void:
	SoundManager.play_sound(SoundManager.player_hurt)
	if health and health.has_method("damage"):
		health.damage(amount, from)
		if shaker_component:
			shaker_component.play_shake()
