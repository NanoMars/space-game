extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 10.0
@export var deceleration: float = 10.0

@onready var health: Health = $Health
@onready var weapon: Weapon = $Weapon

@onready var cam: Camera3D = get_tree().get_first_node_in_group("camera") as Camera3D
@onready var ortho_size: float = cam.size  # In 4.x this is the *diameter* on the locked axis
@onready var viewport_aspect: float = cam.get_viewport().size.aspect() # width / height
@onready var keep_height: bool = cam.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT

# Compute half extents in world units based on keep_aspect
@onready var half_height: float = (ortho_size * 0.5) if keep_height else (ortho_size * 0.5) / viewport_aspect
@onready var half_width: float  = (half_height * viewport_aspect) if keep_height else (ortho_size * 0.5)
@onready var clamp_center: Vector2 = Vector2(cam.global_position.x, cam.global_position.z) # Static center for clamping

@export var shiny_thing_scene: PackedScene

var dead: bool = false
signal died(from: Node)

func _ready() -> void:
	if health:
		health.died.connect(_on_died)

func _physics_process(delta: float) -> void:

	var input_vector: Vector2 = Vector2(
		Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
		Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	)
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var target_velocity: Vector3 = Vector3(input_vector.x, 0.0, input_vector.y) * move_speed

	var rate = acceleration if input_vector != Vector2.ZERO else deceleration

	velocity.x = move_toward(velocity.x, target_velocity.x, rate * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, rate * delta)

	move_and_slide()

	var pos := global_position
	pos.x = clamp(
		pos.x,
		clamp_center.x - half_width,
		clamp_center.x + half_width
	)
	pos.z = clamp(
		pos.z,
		clamp_center.y - half_height,
		clamp_center.y + half_height
	)
	global_position = pos

	# Poll "shoot" action from Input Map
	var shoot_pressed := Input.is_action_pressed("shoot") 
	if weapon:
		weapon.firing = shoot_pressed

func _on_died(_from: Node) -> void:
	if dead:
		return
	
	dead = true
	$MeshInstance3D.visible = false
	self.move_speed = 0.0
	self.velocity = Vector3.ZERO
	var shiny_thing_instance = shiny_thing_scene.instantiate()
	shiny_thing_instance.global_position = self.global_position
	get_parent().add_child(shiny_thing_instance)
	queue_free()

	

func damage(amount: float, from: Node = null) -> void:
	SoundManager.play_sound(SoundManager.player_hurt)
	if health and health.has_method("damage"):
		health.damage(amount, from)
