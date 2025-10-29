extends Node2D

var projectile: Projectile

func _ready() -> void:
	# Get reference to parent projectile
	projectile = get_parent() as Projectile
	if not projectile:
		push_error("ProjectileMover must be a child of a Projectile node")
		return
	
	# Set up initial velocity
	var dir := -projectile.global_transform.y.normalized()
	projectile.linear_velocity = dir * (projectile.weapon_stats.projectile_speed if projectile.weapon_stats else 0.0)

func _physics_process(_delta: float) -> void:
	if not projectile:
		return
	
	# Despawn if outside viewport bounds + exterior padding (no camera)
	var vp_size := get_viewport().get_visible_rect().size
	var left := -projectile.cull_padding
	var right := vp_size.x + projectile.cull_padding
	var top := -projectile.cull_padding
	var bottom := vp_size.y + projectile.cull_padding

	var pos := projectile.global_position
	if projectile.display_mode:
		# Only check Y bounds with padding
		if pos.y < top or pos.y > bottom:
			projectile.queue_free()
			return
	else:
		# Check both X and Y with padding
		if pos.x < left or pos.x > right or pos.y < top or pos.y > bottom:
			projectile.queue_free()
			return

	# Rotate to face movement direction in 2D
	var v: Vector2 = projectile.linear_velocity
	projectile.rotation = v.angle() + PI / 2
