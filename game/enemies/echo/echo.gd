extends Enemy

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var speed: float = 3.0
@export var damage_dealt: float = 20.0

# Note: keeping original names to avoid breaking existing scene data.
# These now apply to the Y axis in 2D.
@export var zspeed: float = 1.5
@export var z_goal_pos: float = 4
@export var sine_size: float = 0.5
var sine_time: float = 0.0

@export var weapon_node: Marker2D

func _ready() -> void:
	super._ready()	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	sine_time += delta / zspeed
	if player:
		var dx: float = player.position.x - position.x
		var dy: float = z_goal_pos - position.y + (sin(sine_time) * sine_size)
		if absf(dx) > 0.001 or absf(dy) > 0.001:
			var dir := Vector2(signf(dx), signf(dy)).normalized()
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
