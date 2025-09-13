extends RigidBody3D

@onready var player: Node = get_tree().get_first_node_in_group("player")
@export var delay: float = 1.0
@export var damage_dealt: float = 50.0
@export var update_frequency: float = 0.1

var transform_history: Array[Transform3D] = []

func _ready() -> void:	
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	player = get_tree().get_first_node_in_group("player")

	var timer := Timer.new()
	timer.wait_time = update_frequency
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_timer_timeout)
	add_child(timer)

	# tween to player transform over delay seconds
	if player:
		var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(self, "transform", player.transform, delay)

func _timer_timeout() -> void:
	if player:
		transform_history.append(player.transform)
		if transform_history.size() > int(delay / update_frequency):
			# tween to that position over update_frequency
			var target_transform: Transform3D = transform_history.pop_front()
			var tween := create_tween().set_trans(Tween.TRANS_LINEAR)
			tween.tween_property(self, "transform", target_transform, update_frequency)



func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
			self.queue_free()
			



