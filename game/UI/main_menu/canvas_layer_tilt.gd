extends CanvasLayer

@export var max_rot_deg := 6.0
@export var max_shift_px := 8.0
@export var ease_speed := 10.0
@export var use_z_rotation := true
@export var noise: FastNoiseLite

@export var use_mouse_pos: bool = true



signal controller_connection_changed(connected: bool)
var controller_connected := false

var _target_rot := Vector2.ZERO
var _current_rot := Vector2.ZERO
var _target_pos := Vector2.ZERO
var _current_pos := Vector2.ZERO
var time: float = 0.0





func _ready() -> void:	
	controller_connected = Input.get_connected_joypads().size() > 0
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	

func _process(delta: float) -> void:
	
	time += delta
	var r := get_viewport().get_visible_rect()
	var size := Vector2(r.size)
	var mouse := get_viewport().get_mouse_position()

	var n: Vector2
	if not use_mouse_pos and is_instance_valid(get_tree().get_first_node_in_group("player") ):
		var player: Node2D = get_tree().get_first_node_in_group("player")
		var player_velocity = player.velocity.normalized()

		var part_1 = player_velocity
		var part_2 = Vector2(
				noise.get_noise_2d(time, 0.0),
				noise.get_noise_2d(0.0, time)
		)
		n = (part_1 + part_2) * 0.5
	else:
		if controller_connected:
			n.x = noise.get_noise_2d(time, 0.0)
			n.y = noise.get_noise_2d(0.0, time)
		else:
			var part_1: Vector2 = Vector2(
				((mouse.x / max(size.x, 1.0)) * 2.0) - 1.0,
				((mouse.y / max(size.y, 1.0)) * 2.0) - 1.0
			)
			var part_2 = Vector2(
				noise.get_noise_2d(time, 0.0),
				noise.get_noise_2d(0.0, time)
			)
			n = (part_1 + part_2) * 0.5
	n = n.clamp(Vector2(-1, -1), Vector2(1, 1))
	

	_target_rot = Vector2(-n.y, n.x) * deg_to_rad(max_rot_deg) # pitch then yaw
	_target_pos = Vector2(n.x, n.y) * max_shift_px

	var t: float = clamp(ease_speed * delta, 0.0, 1.0)
	_current_rot = _current_rot.lerp(_target_rot, t)
	_current_pos = _current_pos.lerp(_target_pos, t)

	var rot_z = (_current_rot.x * 0.35 + _current_rot.y * 0.35) if use_z_rotation else 0.0
	var xf := Transform2D(rot_z, _current_pos)
	transform = xf


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	controller_connected = Input.get_connected_joypads().size() > 0
	controller_connection_changed.emit(controller_connected)

func has_controller_connected() -> bool:
	return controller_connected

func get_connected_controller_count() -> int:
	return Input.get_connected_joypads().size()
