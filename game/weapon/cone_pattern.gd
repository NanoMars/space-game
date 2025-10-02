extends FirePattern
class_name ConePattern

@export var cone_deg: float = 15.0
@export var shots: int = 5

func get_directions() -> Array[ShotSpec]:
	var dirs: Array[ShotSpec] = []
	for i in shots:
		var angle = deg_to_rad(randf_range(-cone_deg, cone_deg))
		var dir = Vector2.UP.rotated(angle)
		dirs.append(ShotSpec.new(dir))
	return dirs
