extends RigidBody2D
class_name Projectile

var weapon_stats: WeaponStats
var last_position: Vector2

@onready var cam: Camera2D = get_tree().get_first_node_in_group("camera") as Camera2D
@onready var viewport_size: Vector2 = Vector2(get_viewport().get_visible_rect().size)
@onready var zoom: Vector2 = cam.zoom if cam else Vector2.ONE
@onready var half_width: float = (viewport_size.x * 0.5) * zoom.x
@onready var half_height: float = (viewport_size.y * 0.5) * zoom.y
@onready var clamp_center: Vector2 = (cam.get_screen_center_position() if cam and cam.has_method("get_screen_center_position") else (cam.global_position if cam else Vector2.ZERO))

var display_mode: bool = false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	# Keep speed consistent
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0

	# Move forward at a constant speed (-Y is "forward" in 2D local space)
	var dir := -global_transform.y.normalized()
	linear_velocity = dir * (weapon_stats.projectile_speed if weapon_stats else 0.0)

	# Track starting position for raycast
	last_position = global_position

func _on_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
		remove_projectile()

func _physics_process(_delta: float) -> void:
	# Raycast from the last position to the current position to catch fast hits
	var current_pos: Vector2 = global_position
	if last_position.distance_to(current_pos) > 0.0001:
		var space_state := get_world_2d().direct_space_state
		var query := PhysicsRayQueryParameters2D.create(last_position, current_pos)
		query.exclude = [self]
		var result := space_state.intersect_ray(query)

		if result.size() > 0:
			var collider: Node = result.get("collider")
			if collider and collider.has_method("damage"):
				collider.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
				remove_projectile()

	# Update for next frame
	last_position = global_position

	# Despawn if outside camera bounds (same region as player clamp)
	if cam:
		var pos := global_position
		if display_mode:
			# Only check Y bounds
			if pos.y < clamp_center.y - half_height \
			or pos.y > clamp_center.y + half_height:
				remove_projectile()
		else:
			# Check both X and Y
			if pos.x < clamp_center.x - half_width \
			or pos.x > clamp_center.x + half_width \
			or pos.y < clamp_center.y - half_height \
			or pos.y > clamp_center.y + half_height:
				remove_projectile()

func remove_projectile() -> void:
	queue_free()
