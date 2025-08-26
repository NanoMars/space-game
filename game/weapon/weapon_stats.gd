extends Resource
class_name WeaponStats

@export var damage: float = 10.0
@export var fire_rate: float = 3.0
@export var spread_deg: float = 0.0
@export var projectile_speed: float = 60.0
@export var projectile_scene: PackedScene



## return an array of unit Vector3 directions (local space) to fire this tick
## 'effective' is a Dictionary with final stats after modifiers
func get_directions(_time: float) -> Array[Vector3]:
	return [Vector3.FORWARD] # default single forward (-Z later after basis transform