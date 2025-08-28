extends Node3D
class_name Weapon

@export var firing: bool:
	set(value):
		
		if shot_timer && value != _firing:
			if _firing:
				print("Stopped firing")
				shot_timer.stop()
			else:
				print("Started firing")
				shot_timer.start()
				
		_firing = value

	get:
		return _firing

var _firing: bool = false
@export var weapon_stats: WeaponStats
var fire_pattern: FirePattern
var shot_timer: Timer
var _time: float = 0.0

func _ready() -> void:
	call_deferred("get_projectile_container")
	if weapon_stats and weapon_stats.fire_pattern:
		fire_pattern = weapon_stats.fire_pattern
	if not shot_timer:
		shot_timer = Timer.new()
		shot_timer.wait_time = 1.0 / weapon_stats.fire_rate
		shot_timer.one_shot = false
		shot_timer.autostart = false
		add_child(shot_timer)
		shot_timer.timeout.connect(fire_once)

func _process(delta: float) -> void:
	_time += delta

func fire_once() -> void:
	SoundManager.play_sound(SoundManager.player_gunshot)
	if not weapon_stats or not fire_pattern:
		return

	var shots: Array[ShotSpec] = fire_pattern.get_directions()
	var container := get_projectile_container()
	var wt := global_transform
	for shot in shots:
		var projectile_instance: Node3D = weapon_stats.projectile_scene.instantiate()

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
