extends Enemy  # Ensure Enemy extends RigidBody2D in 2D

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var speed: float = 300.0   # force magnitude or tweak to taste
@export var damage_dealt: float = 20.0

@export var idle_time: float = 1.0

@export var overshoot_distance: float = 100.0

var postion_target: Vector2

var moving: bool = false
var aiming: bool = true



var idle_timer: Timer

@export var goal_display: Line2D

@export var temp_target: Sprite2D
@export var aiming_speed: float = 200.0

func _ready() -> void:
	super._ready()
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)

	
	idle_timer = Timer.new()
	idle_timer.wait_time = idle_time
	idle_timer.one_shot = true

	add_child(idle_timer)
	idle_timer.timeout.connect(_on_idle_timeout)
	idle_timer.start()

func _on_idle_timeout() -> void:
	
	if player:
		aiming = false
		# Calculate a target position that overshoots the player
		postion_target = temp_target.global_position
		 # Start moving towards the target position
		moving = true
		goal_display.visible = true

func _physics_process(delta: float) -> void:
	if moving and player:
		var direction: Vector2 = (postion_target - global_position).normalized()
		# Apply a force toward the target position (2D). Remove * delta if you want stronger acceleration.
		self.linear_velocity = direction * speed * delta
		goal_display.points = [self.global_position, postion_target]

		# Face the velocity direction in 2D
		var v: Vector2 = linear_velocity
		if v.length_squared() > 0.0001:
			rotation = v.angle() + PI / 2

		# Check if close to the target position
		if global_position.distance_to(postion_target) < 10.0:
			moving = false
			goal_display.visible = false
			self.linear_velocity = Vector2.ZERO
			temp_target.global_position = global_position
			aiming = true
			idle_timer.start()
	elif aiming and player and temp_target:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		var goal_position: Vector2 = player.global_position + direction * overshoot_distance
		var diff: Vector2 = goal_position - temp_target.global_position
		temp_target.global_position += diff * delta * aiming_speed

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
		if health and health.has_method("die"):
			health.die(self)
