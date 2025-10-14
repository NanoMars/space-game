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
var homing_level: int = 0

@export var homing_strength_per_level: float = 100.0

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
	for modifier in ScoreManager.active_modifiers:
		if modifier.display_name == "homing bullets":
			homing_level = modifier.stacks
			break

func _on_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage((weapon_stats.damage if weapon_stats and typeof(weapon_stats.damage) == TYPE_FLOAT else 0.0), self)
		queue_free()
		return

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
				queue_free()
				return

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
			queue_free()
			return
	else:
		# Check both X and Y with padding
		if pos.x < left or pos.x > right or pos.y < top or pos.y > bottom:
			queue_free()
			return

	# rotate to face movement direction in 2D
	var v: Vector2 = linear_velocity
	rotation = v.angle() + PI / 2
	var velocity_length = v.length()
	trail_age += _delta
	trail.scale.y = trail_1px * velocity_length * min(trail_age, trail_size_seconds)
	if homing_level > 0:
		var nearest_enemy: Node2D = null
		var nearest_dist: float = 1e10
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy and enemy is Node2D:
				var dist: float = enemy.global_position.distance_to(global_position)
				if dist < nearest_dist:
					nearest_dist = dist
					nearest_enemy = enemy

		if nearest_enemy:
			var to_enemy: Vector2 = (nearest_enemy.global_position - global_position).normalized()
			var current_dir: Vector2 = linear_velocity.normalized()
			var angle_diff: float = current_dir.angle_to(to_enemy)
			var angle_change: float = homing_strength_per_level * homing_level * _delta / max(velocity_length, 0.0001)
			angle_change = min(abs(angle_diff), angle_change) * sign(angle_diff)
			var new_dir: Vector2 = current_dir.rotated(angle_change).normalized()
			linear_velocity = new_dir * velocity_length


