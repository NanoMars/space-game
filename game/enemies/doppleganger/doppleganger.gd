extends Enemy

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var delay: float = 1.0
@export var damage_dealt: float = 50.0
@export var update_frequency: float = 0.1
@export var ambient_sound: AudioStreamPlayer

var transform_history: Array[Transform2D] = []
@export var random_range: Vector2

func _ready() -> void:
	super._ready()
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("player") as Node2D

	var timer: Timer = Timer.new()
	timer.wait_time = update_frequency
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_timer_timeout)
	add_child(timer)

	# Tween to player's current transform over delay seconds
	if player:
		var tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "global_transform", player.global_transform, delay)
	ambient_sound.finished.connect(ambient_sound_timeout)
	ambient_sound.play()

func ambient_sound_timeout() -> void:
	await get_tree().create_timer(randf_range(random_range.x, random_range.y)).timeout
	ambient_sound.play()

func _timer_timeout() -> void:
	if player:
		transform_history.append(player.global_transform)
		if transform_history.size() > int(delay / update_frequency):
			# Tween to the oldest saved transform over update_frequency
			var target_transform: Transform2D = transform_history.pop_front()
			var tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(self, "global_transform", target_transform, update_frequency)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
		queue_free()
