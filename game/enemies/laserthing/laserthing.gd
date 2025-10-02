extends Enemy  # Ensure Enemy extends RigidBody2D in 2D

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var damage_dealt: float = 20.0

# Sine-wave parameters
@export var amplitude: float = 120.0        # pixels
@export var frequency_hz: float = 0.75      # cycles per second
@export var vertical_speed: float = 120.0   # pixels per second downward
@export var raycast_l: RayCast2D
@export var raycast_r: RayCast2D

var _t: float = 0.0
var _phase: float = 0.0
var _center_x: float = 0.0

func _ready() -> void:
	super._ready()
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

	# Remove gravity/damp so y stays constant
	if has_node("."): # RigidBody2D
		gravity_scale = 0.0
		linear_damp = 0.0

	# random phase and fixed screen center
	_phase = randf_range(0.0, TAU)
	_center_x = get_viewport().get_visible_rect().size.x * 0.5

	# start at the correct x for this phase
	global_position.x = _center_x + amplitude * sin(_phase)

func _physics_process(delta: float) -> void:
	_t += delta
	var w := TAU * frequency_hz

	# Lock x to sine around center every frame
	global_position.x = _center_x + amplitude * sin(w * _t + _phase)

	# Only move down at constant speed
	linear_velocity.x = 0.0
	linear_velocity.y = vertical_speed

	# raycast to detect player
	if raycast_l.is_colliding():
		var collider: Node = raycast_l.get_collider()
		if collider and collider.is_in_group("player"):
			_on_body_entered(collider)
	if raycast_r.is_colliding():
		var collider: Node = raycast_r.get_collider()
		if collider and collider.is_in_group("player"):
			_on_body_entered(collider)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
		if health and health.has_method("die"):
			health.die(self)
