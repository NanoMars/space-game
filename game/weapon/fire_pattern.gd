extends Resource
class_name FirePattern

## return an array of unit Vector3 directions (local space) to fire this tick
func get_directions() -> Array[ShotSpec]:
	return [ShotSpec.new(Vector3.FORWARD)] # default single forward (-Z later after basis transform)