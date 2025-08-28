extends Enemy

@onready var player: Node = get_tree().get_first_node_in_group("player")
@export var speed: float = 3.0
@export var damage_dealt: float = 20.0


func _ready() -> void:
	super._ready()
	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if player:
		var direction: Vector2 = Vector2(player.position.x - position.x, player.position.z - position.z).normalized()
		apply_force(Vector3(direction.x, 0.0, direction.y) * speed * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
			if health and health.has_method("die"):
				health.die(self)


