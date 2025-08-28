extends RigidBody3D
class_name Projectile

var weapon_stats: WeaponStats
var last_position: Vector3

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
	# Track starting position for raycast
	last_position = global_position

func _on_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
		remove_projectile()

func _physics_process(_delta: float) -> void:
	# Raycast from the last position to the current position to catch fast hits
	var current_pos: Vector3 = global_position
	if last_position.distance_to(current_pos) > 0.0001:
		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(last_position, current_pos)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)
		if result.size() > 0:
			var collider: Node = result.get("collider")
			if collider and collider.has_method("damage"):
				collider.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
				remove_projectile()
	# Update for next
	last_position = global_position

func remove_projectile() -> void:
	queue_free()
