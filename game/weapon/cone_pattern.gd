extends FirePattern
class_name ConePattern

@export var cone_deg: float = 15.0
@export var shots: int = 15

func get_directions() -> Array[ShotSpec]:
	var dirs: Array[ShotSpec] = []
	for i in shots:
		var t = float(i) / float(shots - 1) if shots > 1 else 0.5
		var angle = deg_to_rad(lerp(-cone_deg, cone_deg, t))
		var dir = Vector2.UP.rotated(angle)
		dirs.append(ShotSpec.new(dir))
	return dirs
