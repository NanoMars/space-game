extends FirePattern
class_name ConePattern

@export var cone_deg: float = 15.0
@export var shots: int = 5

func get_directions() -> Array[ShotSpec]:
	var dirs: Array[ShotSpec] = []
	for i in int(shots):
		var yaw = randf_range(-cone_deg, cone_deg)
		var dir = Basis(Vector3.UP, deg_to_rad(yaw)) * Vector3.FORWARD
		dirs.append(ShotSpec.new(dir))
	return dirs
