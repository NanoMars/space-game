extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 10.0
@export var deceleration: float = 10.0

@onready var health: Health = $Health

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

func _on_died(from: Node) -> void:
	queue_free()

func damage(amount: float, from: Node = null) -> void:
	if health and health.has_method("damage"):
		health.damage(amount, from)
