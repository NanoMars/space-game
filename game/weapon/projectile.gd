extends RigidBody3D
class_name Projectile

var weapon_stats: WeaponStats

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	# Keep speed consistent
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	# Move forward at a constant speed (-Z is forward in Godot)
	linear_velocity = global_transform.basis.z * weapon_stats.projectile_speed

func _on_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
