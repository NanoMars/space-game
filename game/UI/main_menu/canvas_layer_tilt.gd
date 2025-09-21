# Node: CanvasLayer or your top Control
extends CanvasLayer

@export var max_rot_deg := 6.0      # how much it can tilt left right and up down
@export var max_shift_px := 24.0    # how much it can nudge
@export var ease_speed := 10.0      # higher is snappier
@export var use_z_rotation := true  # add a small z roll for extra depth

var _target_rot := Vector2.ZERO     # x = pitch up down, y = yaw left right
var _current_rot := Vector2.ZERO
var _target_pos := Vector2.ZERO
var _current_pos := Vector2.ZERO

func _ready() -> void:
	# CanvasLayer: children are already in canvas space
	pass

func _process(delta: float) -> void:
	var r := get_viewport().get_visible_rect()
	var size := Vector2(r.size)
	var mouse := get_viewport().get_mouse_position()

	# normalize mouse to [-1, 1] with 0,0 at center
	var n := Vector2(
		((mouse.x / max(size.x, 1.0)) * 2.0) - 1.0,
		((mouse.y / max(size.y, 1.0)) * 2.0) - 1.0
	)
	n = n.clamp(Vector2(-1, -1), Vector2(1, 1))

	# set targets
	_target_rot = Vector2(-n.y, n.x) * deg_to_rad(max_rot_deg) # pitch then yaw
	_target_pos = Vector2(n.x, n.y) * max_shift_px

	# smooth
	var t: float = clamp(ease_speed * delta, 0.0, 1.0)
	_current_rot = _current_rot.lerp(_target_rot, t)
	_current_pos = _current_pos.lerp(_target_pos, t)

	# apply transform (CanvasLayer transform)
	var rot_z = (_current_rot.x * 0.35 + _current_rot.y * 0.35) if use_z_rotation else 0.0
	var xf := Transform2D(rot_z, _current_pos)
	transform = xf
