extends Node

@export var wobbly_nodes: Array[Control] = []
@export var pos_wobble_amount: float = 5.0      # pixels
@export var pos_wobble_speed: float = 5.0       # time step multiplier
@export var rot_wobble_amount: float = 5.0      # degrees
@export var rot_wobble_speed: float = 5.0       # time step multiplier

@export var pos_wobble_scale: float = 1.0       # spatial scale (frequency) for position noise
@export var rot_wobble_scale: float = 1.0       # spatial scale (frequency) for rotation noise

var _rng := RandomNumberGenerator.new()
var _t_pos := 0.0
var _t_rot := 0.0

# Per-node data: {pos: Vector2, rot_deg: float, xoff: float, yoff: float, roff: float, noise: FastNoiseLite}
var _node_data: Dictionary[Control, Dictionary] = {}

func _ready() -> void:
	_rng.randomize()

	_node_data.clear()
	for n in wobbly_nodes:
		if not is_instance_valid(n):
			continue

		var noise := FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		noise.seed = _rng.randi()
		# Keep base frequency at 1.0; we modulate via pos_wobble_scale/rot_wobble_scale.
		noise.frequency = 1.0

		_node_data[n] = {
			"pos": n.position,
			"rot_deg": n.rotation_degrees,
			"xoff": _rng.randf_range(-10000.0, 10000.0),
			"yoff": _rng.randf_range(-10000.0, 10000.0),
			"roff": _rng.randf_range(-10000.0, 10000.0),
			"noise": noise,
		}

	set_process(true)

func _process(delta: float) -> void:
	if _node_data.is_empty():
		return

	_t_pos += delta * pos_wobble_speed
	_t_rot += delta * rot_wobble_speed

	for n in wobbly_nodes:
		if not is_instance_valid(n):
			continue
		if not _node_data.has(n):
			continue

		var d: Dictionary = _node_data[n]
		var noise := d["noise"] as FastNoiseLite

		# Sample smooth Perlin in [-1, 1]
		var nx := noise.get_noise_2d(_t_pos * pos_wobble_scale, d["xoff"] as float)
		var ny := noise.get_noise_2d(_t_pos * pos_wobble_scale, d["yoff"] as float)
		var nr := noise.get_noise_2d(_t_rot * rot_wobble_scale, d["roff"] as float)

		# Apply offsets
		n.position = (d["pos"] as Vector2) + Vector2(nx, ny) * pos_wobble_amount
		n.rotation_degrees = (d["rot_deg"] as float) + nr * rot_wobble_amount

func reset_wobble_baselines() -> void:
	# Call this if you change layout at runtime and want new baselines.
	for n in wobbly_nodes:
		if not is_instance_valid(n):
			continue
		if _node_data.has(n):
			_node_data[n]["pos"] = n.position
			_node_data[n]["rot_deg"] = n.rotation_degrees
