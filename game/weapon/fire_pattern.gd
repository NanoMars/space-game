# fire_pattern.gd (2D version)
extends Resource
class_name FirePattern

## return an array of unit Vector2 directions (local space) to fire this tick
func get_directions() -> Array[ShotSpec]:
	return [ShotSpec.new(Vector2.UP)] # default single forward (up in 2D)