# projectile.gd
extends RigidBody3D
class_name Projectile

var weapon_stats: WeaponStats
var last_position: Vector3

# Camera bounds (same logic as player.gd)
@onready var cam: Camera3D = get_tree().get_first_node_in_group("camera") as Camera3D
@onready var ortho_size: float = (cam.size if cam else 0.0)  # In 4.x this is the diameter on the locked axis
@onready var viewport_aspect: float = (cam.get_viewport().size.aspect() if cam else 1.0) # width / height
@onready var keep_height: bool = (cam and cam.keep_aspect == Camera3D.KeepAspect.KEEP_HEIGHT)

# Compute half extents in world units based on keep_aspect
@onready var half_height: float = ( (ortho_size * 0.5) if keep_height else (ortho_size * 0.5) / viewport_aspect ) if cam else 0.0
@onready var half_width: float  = ( (half_height * viewport_aspect) if keep_height else (ortho_size * 0.5) ) if cam else 0.0
@onready var clamp_center: Vector2 = (Vector2(cam.global_position.x, cam.global_position.z) if cam else Vector2.ZERO) # Static center for bounds

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
		# Debug: show ray start/end and distance moved this frame
		var moved_dist := last_position.distance_to(current_pos)

		var space_state := get_world_3d().direct_space_state
		var query := PhysicsRayQueryParameters3D.create(last_position, current_pos)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)

		if result.size() > 0:
			var collider: Node = result.get("collider")
			var hit_pos: Vector3 = result.get("position")
			var hit_normal: Vector3 = result.get("normal")

			if collider and collider.has_method("damage"):	
				collider.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
				remove_projectile()

	# Update for next
	last_position = global_position

	# Despawn if outside camera bounds (same region as player clamp)
	if cam:
		var pos := global_position
		if pos.x < clamp_center.x - half_width \
		or pos.x > clamp_center.x + half_width \
		or pos.z < clamp_center.y - half_height \
		or pos.z > clamp_center.y + half_height:
			remove_projectile()

func remove_projectile() -> void:
	queue_free()
