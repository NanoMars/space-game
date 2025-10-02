extends Enemy

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D

@export var speed: float = 3.0
@export var damage_dealt: float = 20.0

# 2D vertical oscillation settings
@export var vertical_osc_period: float = 1.5  # seconds per cycle
@export var target_y: float = 4.0             # baseline Y position to hover around
@export var vertical_sine_amplitude: float = 0.5

var sine_time: float = 0.0

@export var weapon_node: Marker2D

func _ready() -> void:
	super._ready()
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if not player:
		return

	# Advance vertical oscillation time
	var period: float = max(vertical_osc_period, 0.0001)
	sine_time += delta / period
	var desired_y: float = target_y + sin(sine_time) * vertical_sine_amplitude

	# Seek player.x while oscillating on Y around target_y
	var dx: float = player.position.x - position.x
	var dy: float = desired_y - position.y
	var to_target: Vector2 = Vector2(dx, dy)

	if to_target.length_squared() > 1e-6:
		var dir := to_target.normalized()
		apply_force(dir * speed * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
			if health and health.has_method("die"):
				health.die(self)

func _on_health_damaged(amount: float, from: Node) -> void:
	if weapon_node and weapon_node.has_method("fire_once"):
		weapon_node.fire_once()
