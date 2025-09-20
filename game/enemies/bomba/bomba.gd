extends Enemy

@onready var player: Node = get_tree().get_first_node_in_group("player")
@export var speed: float = 3.0
@export var damage_dealt: float = 20.0

var goal_pos: Vector2

@export var random_area: Vector2 = Vector2(7.0, 3.5)

@export var beeps_to_explode: int = 50
@export var initial_beep_interval: float = 0.5
@export var min_beep_interval: float = 0.05
@export var beep_acceleration: float = 0.90

@onready var weapon_node: Marker3D = $Weapon

var timer: Timer


func _ready() -> void:
	super._ready()
	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

	goal_pos = Vector2(randf_range(-random_area.x, random_area.x), randf_range(-random_area.y, random_area.y))

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = initial_beep_interval
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false
	timer.start()

func _on_timer_timeout() -> void:
	beeps_to_explode -= 1
	print(beeps_to_explode)
	SoundManager.play_sound(SoundManager.bomb_beep)
	if beeps_to_explode <= 0:
		explode()
	else:
		initial_beep_interval = max(initial_beep_interval * beep_acceleration, min_beep_interval)
		timer.wait_time = initial_beep_interval

func _physics_process(delta: float) -> void:
	var dx: float = goal_pos.x - position.x
	var dz: float = goal_pos.y - position.z
	if absf(dx) > 0.001 or absf(dz) > 0.001:
		var dir := Vector3(signf(dx), 0.0, signf(dz)).normalized()
		apply_force(dir * speed * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			explode()

func explode() -> void:
	weapon_node.fire_once()
	if health and health.has_method("die"):
		health.die(self)
