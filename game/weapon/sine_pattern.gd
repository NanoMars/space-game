# sine_pattern.gd (2D version)
extends FirePattern
class_name SinePattern

@export var shots: int = 2
@export var sine_step: float = 0.1
@export var sin_angle: float = 15.0

var shot_count: int = 0

func get_directions() -> Array[ShotSpec]:
	var dirs: Array[ShotSpec] = []
	for i in shots:
		var angle = sin((shot_count * sine_step) + (2 * PI) / (i + 1)) * sin_angle
		var dir = Vector2.UP.rotated(deg_to_rad(angle))
		dirs.append(ShotSpec.new(dir))
		shot_count += 1
	return dirs
