extends Enemy

@onready var player: Node = get_tree().get_first_node_in_group("player")
@export var speed: float = 3.0
@export var damage_dealt: float = 20.0
@export var zspeed: float = 1.5
@export var z_goal_pos: float = 4
@export var sine_size: float = 0.5
var sine_time: float = 0.0

@export var weapon_node: Marker3D

func _ready() -> void:
	super._ready()
	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	sine_time += delta / zspeed
	if player:
		var dx: float = player.position.x - position.x
		var dz: float = z_goal_pos - position.z + ( sin(sine_time) * sine_size )
		if absf(dx) > 0.001:
			var dir := Vector3(signf(dx), 0.0, signf(dz)).normalized()
			apply_force(dir * speed * delta)

	

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
			if health and health.has_method("die"):
				health.die(self)




func _on_health_damaged(amount:float, from:Node) -> void:
	print("shoot")
	weapon_node.fire_once()
