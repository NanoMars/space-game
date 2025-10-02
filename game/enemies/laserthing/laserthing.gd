extends Enemy

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var speed: float = 3.0
@export var damage_dealt: float = 35.0
@onready var raycast_l: RayCast2D = $RayCastL
@onready var raycast_r: RayCast2D = $RayCastR

@export var horizontal_padding: float = 5.5

@export var weapon_node: Marker2D
@export var wave_hz: float = 0.25 # lateral oscillation frequency (cycles per second)

var _time: float = 0.0
var _phase: float = 0.0
var _omega: float = 0.0

func _damage_player(target: Node) -> void:
	if target and target.is_in_group("player") and target.has_method("damage"):
		target.damage(damage_dealt, self)
		if health and health.has_method("die"):
			health.die(self)

func _ready() -> void:
	super._ready()
	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

	# Initialize sine wave parameters based on current x
	_omega = TAU * wave_hz
	# Compute bounds from viewport width
	var vw: float = float(get_viewport_rect().size.x)
	var min_x: float = horizontal_padding
	var max_x: float = vw - horizontal_padding
	var mid: float = (min_x + max_x) * 0.5
	var amp: float = max((max_x - min_x) * 0.5, 0.0)
	if amp > 0.0 and _omega != 0.0:
		var s: float = clamp((position.x - mid) / amp, -1.0, 1.0)
		_phase = asin(s) # phase that matches the current x relative to [min_x, max_x]
	else:
		_phase = 0.0

func _physics_process(delta: float) -> void:
	# Forward movement along -Y (upwards)
	var dir := Vector2(0.0, -1.0)
	apply_force(dir * speed * delta)

	# Sine-wave lateral motion between [horizontal_padding, viewport_width - horizontal_padding]
	var vw: float = float(get_viewport_rect().size.x)
	var min_x: float = horizontal_padding
	var max_x: float = vw - horizontal_padding
	var mid: float = (min_x + max_x) * 0.5
	var amp: float = max((max_x - min_x) * 0.5, 0.0)

	if amp > 0.0 and _omega != 0.0:
		_time += delta
		var new_x := mid + amp * sin(_omega * _time + _phase)
		var p := position
		p.x = new_x
		position = p
	else:
		# Fallback clamp if no wave configured
		position.x = clamp(position.x, min_x, max_x)

	if raycast_l.is_colliding():
		var collider_l: Node = raycast_l.get_collider() as Node
		_damage_player(collider_l)

	if raycast_r.is_colliding():
		var collider_r: Node = raycast_r.get_collider() as Node
		_damage_player(collider_r)

func _on_body_entered(body: Node) -> void:
	_damage_player(body)