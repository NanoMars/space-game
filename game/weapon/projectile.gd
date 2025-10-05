extends RigidBody2D
class_name Projectile

@export var cull_padding: float = 64.0

var weapon_stats: WeaponStats
var last_position: Vector2

var display_mode: bool = false

@export var trail: Sprite2D = null
@export var trail_1px: float = 0.015
@export var trail_size_seconds: float = 0.25

var trail_log: Array[Vector2] = []
var trail_age: float = 0.0

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

	# Despawn if outside viewport bounds + exterior padding (no camera)
	var vp_size := get_viewport().get_visible_rect().size
	var left := -cull_padding
	var right := vp_size.x + cull_padding
	var top := -cull_padding
	var bottom := vp_size.y + cull_padding

	var pos := global_position
	if display_mode:
		# Only check Y bounds with padding
		if pos.y < top or pos.y > bottom:
			remove_projectile()
	else:
		# Check both X and Y with padding
		if pos.x < left or pos.x > right or pos.y < top or pos.y > bottom:
			remove_projectile()

	# rotate to face movement direction in 2D
	var v: Vector2 = linear_velocity
	rotation = v.angle() + PI / 2
	var velocity_length = v.length()
	trail_age += _delta
	trail.scale.y = trail_1px * velocity_length * min(trail_age, trail_size_seconds)


func remove_projectile() -> void:
	queue_free()
