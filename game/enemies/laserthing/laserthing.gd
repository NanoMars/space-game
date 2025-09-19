extends Enemy

@onready var player: Node = get_tree().get_first_node_in_group("player")
@export var speed: float = 3.0
@export var damage_dealt: float = 35.0

@export var damage_tick: float = 0.1

@onready var raycast_l: RayCast3D = $RayCastL
@onready var raycast_r: RayCast3D = $RayCastR

@export var max_x: float = 5.5

@export var weapon_node: Marker3D
@export var wave_hz: float = 0.25 # lateral oscillation frequency (cycles per second)

var _time: float = 0.0
var _phase: float = 0.0
var _omega: float = 0.0

func _ready() -> void:
	super._ready()
	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = damage_tick
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false
	timer.start()

	# Initialize sine wave parameters based on current random x
	_omega = TAU * wave_hz
	if max_x > 0.0 and _omega != 0.0:
		var s: float = clamp(position.x / max_x, -1.0, 1.0)
		_phase = asin(s) # picks the phase that matches the current x
	else:
		_phase = 0.0

func _physics_process(delta: float) -> void:
	# Forward movement stays the same
	var dir := Vector3(0.0, 0.0, -speed).normalized()
	apply_force(dir * speed * delta)

	# Sine-wave lateral motion between -max_x and max_x
	if max_x > 0.0 and _omega != 0.0:
		_time += delta
		var new_x := max_x * sin(_omega * _time + _phase)
		var p := position
		p.x = new_x
		position = p
	else:
		# Fallback clamp if no wave configured
		if position.x < -max_x:
			position.x = -max_x
		elif position.x > max_x:
			position.x = max_x

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
			if health and health.has_method("die"):
				health.die(self)

func _on_timer_timeout() -> void:
	if raycast_l.is_colliding():
		var collider: Node = raycast_l.get_collider() as Node
		if collider and collider.is_in_group("player"):
			if collider.has_method("damage"):
				collider.damage(damage_dealt, self)
				if health and health.has_method("die"):
					health.die(self)
	if raycast_r.is_colliding():
		var collider: Node = raycast_r.get_collider() as Node
		if collider and collider.is_in_group("player"):
			if collider.has_method("damage"):
				collider.damage(damage_dealt, self)
				if health and health.has_method("die"):
					health.die(self)
