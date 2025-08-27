extends Resource
class_name FirePattern

## return an array of unit Vector3 directions (local space) to fire this tick
## 'effective' is a Dictionary with final stats after modifiers
func get_directions(effective: Dictionary) -> Array[Vector3]:
	return [Vector3.FORWARD] # default single forward (-Z later after basis transform)