extends Enemy  # Ensure Enemy extends RigidBody2D in 2D

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var speed: float = 300.0   # force magnitude or tweak to taste
@export var damage_dealt: float = 20.0

func _ready() -> void:
	super._ready()
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if player:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		# Apply a force toward the player (2D). Remove * delta if you want stronger acceleration.
		apply_force(direction * speed * delta)

	# Face the velocity direction in 2D
	var v: Vector2 = linear_velocity
	if v.length_squared() > 0.0001:
		rotation = v.angle()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
		if health and health.has_method("die"):
			health.die(self)
