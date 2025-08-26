extends Node3D
class_name Weapon

signal fired

@export var stats: WeaponStats
@export var pattern: FirePattern

@onready var muzzle: Node3D = $Muzzle

var _cooldown: float = 0.0
var _burst_left: int = 0
var _burst_timer: float = 0.0
var _trigger_down: bool = false

# timed modifiers
class ActiveMod:
	var mod: WeaponModifier
	var stacks: int = 1
	var expires_at: float = INF
	func _init(m: WeaponModifier, s: int, t: float) -> void:
		mod = m; stacks = s; expires_at = t

var _mods: Array[ActiveMod] = []

func hold_trigger() -> void:
	_trigger_down = true

func release_trigger() -> void:
	_trigger_down = false
	_burst_left = 0
	_burst_timer = 0.0

func add_modifier(mod: WeaponModifier, duration_sec: float = 0.0, stacks: int = 1) -> void:
	# merge stacks by id if present
	for a in _mods:
		if a.mod.id == mod.id:
			a.stacks = clamp(a.stacks + stacks, 1, mod.max_stacks)
			a.expires_at = max(a.expires_at, (Engine.get_physics_time() + duration_sec) if duration_sec > 0.0 else INF)
			return
	var expire_time = (Engine.get_physics_time() + duration_sec) if duration_sec > 0.0 else INF
	_mods.append(ActiveMod.new(mod, stacks, expire_time))

func _physics_process(delta: float) -> void:
	# prune expired
	var now = Engine.get_physics_time()
	_mods = _mods.filter(func(a): return a.expires_at > now)

	# cooldown
	if _cooldown > 0.0:
		_cooldown -= delta

	# handle burst cadence
	if _burst_left > 0:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_fire_once()
			_burst_left -= 1
			_burst_timer = max(stats.burst_delay, 0.0)

	# pull trigger
	if _trigger_down and _cooldown <= 0.0 and _burst_left == 0:
		var eff = _effective()
		_fire_once(eff)
		_burst_left = max(eff.burst_count - 1, 0)
		_burst_timer = max(eff.burst_delay, 0.0)
		_cooldown = 1.0 / max(eff.fire_rate, 0.001)

func _effective() -> Dictionary:
	var e := {
		"damage": stats.base_damage,
		"fire_rate": stats.fire_rate,
		"projectile_speed": stats.projectile_speed,
		"spread_deg": stats.spread_deg,
		"shots_per_trigger": stats.shots_per_trigger,
		"burst_count": stats.burst_count,
		"burst_delay": stats.burst_delay,
		"max_pierce": stats.max_pierce,
		"projectile_scene": stats.projectile_scene,
	}
	for a in _mods:
		a.mod.apply(e, a.stacks)
	return e

func _fire_once(e: Dictionary = _effective()) -> void:
	if e.projectile_scene == null or muzzle == null:
		return
	# directions from pattern
	var dirs: Array[Vector3] = []
	if pattern:
		dirs = pattern.get_directions(e)
	else:
		dirs = [Vector3.FORWARD]

	# apply small uniform spread if requested
	if e.spread_deg > 0.0:
		for i in dirs.size():
			var yaw = randf_range(-e.spread_deg, e.spread_deg)
			dirs[i] = Basis(Vector3.UP, deg_to_rad(yaw)) * dirs[i]

	for dir in dirs:
		var t = muzzle.global_transform
		# Godot forward is -Z; our pattern uses +FWD = -Z after basis transform
		var world_dir = (t.basis * dir).normalized()
		var p = e.projectile_scene.instantiate()
		p.global_transform.origin = t.origin
		if p.has_method("setup"):
			p.setup(world_dir, e.projectile_speed, e.damage, e.max_pierce, get_parent()) # from = player
		get_tree().current_scene.add_child(p)
	emit_signal("fired")
