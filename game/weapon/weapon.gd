extends Marker3D
class_name Weapon

@export var firing: bool:
	set(value):
		
		if shot_timer && value != _firing:
			_firing = value

			if _firing:
				if can_shoot:
					fire_once()
					shot_timer.start()
					print("Starting shot timer")
			else:
				pass
				
		print("Firing set to: ", _firing)
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
		print("Weapon fire rate: ", weapon_stats.fire_rate, " wait time: ", shot_timer.wait_time)
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
	var wt := global_transform
	for shot in shots:
		var projectile_instance: Node3D = weapon_stats.projectile_scene.instantiate()
		projectile_instance.display_mode = display_mode
		# Convert local shot spec to world
		var g_dir := (wt.basis * shot.dir).normalized()
		var g_pos := wt.origin + wt.basis * (shot.offset if shot.has_method("offset") == false else shot.offset) # offset defaults to ZERO

		# Build transform: -Z faces g_dir (Godot forward)
		var shot_basis := Basis.looking_at(g_dir, Vector3.UP)
		projectile_instance.global_transform = Transform3D(shot_basis, g_pos)

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
