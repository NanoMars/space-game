extends Marker2D
class_name Weapon

@export var firing: bool:
	set(value):
		if shot_timer and value != _firing:
			_firing = value

			if _firing:
				if can_shoot:
					fire_once()
					shot_timer.start()
			else:
				pass
				
	get:
		return _firing

var _firing: bool = false
@export var weapon_stats: WeaponStats:
	set(value):
		_weapon_stats = value
		setup_weapon()
	get:
		return _weapon_stats
var _weapon_stats: WeaponStats = null
@export var display_mode: bool = false
var fire_pattern: FirePattern
var shot_timer: Timer
var _time: float = 0.0

var can_shoot: bool = true
	
func setup_weapon() -> void:
	call_deferred("get_projectile_container")
	if weapon_stats and weapon_stats.fire_pattern:
		fire_pattern = weapon_stats.fire_pattern
	if not shot_timer:
		shot_timer = Timer.new()
		shot_timer.wait_time = 1.0 / weapon_stats.fire_rate
		shot_timer.one_shot = false
		shot_timer.autostart = true
		add_child(shot_timer)
		shot_timer.timeout.connect(_shot_timer_timeout)

func _process(delta: float) -> void:
	_time += delta

func _shot_timer_timeout() -> void:
	can_shoot = true
	if firing:
		fire_once()

func fire_once() -> void:
	can_shoot = false
	if not display_mode:
		SoundManager.play_sound(SoundManager.player_gunshot)
	if not weapon_stats or not fire_pattern:
		return

	var shots: Array[ShotSpec] = fire_pattern.get_directions()
	var container := get_projectile_container()
	var wt: Transform2D = global_transform

	for shot in shots:
		var projectile_instance: Node2D = weapon_stats.projectile_scene.instantiate()
		projectile_instance.display_mode = display_mode

		# Local spec -> world space
		var local_dir: Vector2 = Vector2.UP
		if shot and shot.has_method("get"):
			var d = shot.get("dir")
			if typeof(d) == TYPE_VECTOR2:
				local_dir = d

		var local_off: Vector2 = Vector2.ZERO
		if shot and shot.has_method("get"):
			var o = shot.get("offset")
			if typeof(o) == TYPE_VECTOR2:
				local_off = o

		var g_dir := local_dir.rotated(global_rotation).normalized()
		var g_pos := global_position + local_off.rotated(global_rotation)

		# Align projectile so that -Y faces g_dir (projectile.gd uses -global_transform.y)
		projectile_instance.global_position = g_pos
		projectile_instance.global_rotation = (g_dir.rotated(PI * 0.5)).angle()

		projectile_instance.weapon_stats = weapon_stats
		container.add_child(projectile_instance)

func get_projectile_container() -> Node:
	var root := get_tree().root
	var projectile_parent := root.get_node_or_null("Projectiles")
	if projectile_parent:
		return projectile_parent
	var folder := Node.new()
	folder.name = "Projectiles"
	root.call_deferred("add_child", folder)
	return folder
