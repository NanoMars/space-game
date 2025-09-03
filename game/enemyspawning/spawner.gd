extends Node

@export var total_kills: int = 30
@export var concurrent_cap: int = 8
@export var min_spawn_delay: float = 1.0
@export var max_spawn_delay: float = 5.0
@export var enemy_types: Array[EnemyType] = []
@export var spawn_points: Array[Marker3D] = []
@export var auto_prepare_on_ready: bool = true

var _alive := 0
var _spawn_bag: Array[EnemyType] = []
var _spawn_timer: float = 0.0
var _next_delay: float = 0.4
var _remaining_to_spawn: int = 0
var _killed: int = 0
var _rng := RandomNumberGenerator.new()
var _wave_prepared := false

func _ready() -> void:
	_rng.randomize()
	print("[Spawner] _ready: enemy_types=", enemy_types.size(), " spawn_points=", spawn_points.size(), " total_kills=", total_kills, " concurrent_cap=", concurrent_cap, " min_delay=", min_spawn_delay, " max_delay=", max_spawn_delay)
	if enemy_types.is_empty():
		print("[Spawner] Warning: enemy_types is empty. No enemies can be prepared.")
	if spawn_points.is_empty():
		print("[Spawner] Warning: spawn_points is empty. Nowhere to spawn.")
	print("[Spawner] Note: _prepare_wave() has not been called yet. _remaining_to_spawn=", _remaining_to_spawn, " spawn_bag size=", _spawn_bag.size())
	if auto_prepare_on_ready:
		print("[Spawner] Auto preparing wave in _ready")
		_prepare_wave()

func _process(delta: float) -> void:
	# Auto-prepare once as a fallback if not prepared and data is present
	if not _wave_prepared and not enemy_types.is_empty() and not spawn_points.is_empty():
		print("[Spawner] Auto-detect: wave not prepared; preparing now from _process()")
		_prepare_wave()
	if _killed >= total_kills:
		print("[Spawner] Round complete: killed=", _killed, " total_kills=", total_kills)
		_wave_prepared = false
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		print("[Spawner] Spawn tick: timer=", _spawn_timer, " alive=", _alive, "/", concurrent_cap, " remaining_to_spawn=", _remaining_to_spawn)
		_try_spawn_tick()
		_next_delay = lerp(min_spawn_delay, max_spawn_delay, _rng.randf())
		_spawn_timer = _next_delay
		print("[Spawner] Next spawn in ", _next_delay, "s")

func _prepare_wave():
	print("prepare wave called! --------")
	if enemy_types.is_empty():
		print("[Spawner] _prepare_wave: enemy_types is empty. Aborting.")
		return

	var sum_w := 0.0
	for t in enemy_types:
		sum_w += max(t.weight, 0.0)
		print("[Spawner]   type=", t, " weight=", t.weight)
	print("[Spawner] Sum weight=", sum_w)

	var ideals: Array[float] = []
	for t in enemy_types:
		var w = max(t.weight, 0.0)
		ideals.append(w / sum_w * float(total_kills))
	print("[Spawner] ideals (target counts)=", ideals)

	var floors: Array[int] = []
	var fracs: Array[float] = []
	var used := 0
	for v in ideals:
		var f = int(floor(v))
		floors.append(f)
		fracs.append(v - float(f))
		used += f
	print("[Spawner] floors(before remainder)=", floors, " used=", used)

	var remainder := total_kills - used
	var indecies := []
	indecies.resize(enemy_types.size())
	for i in indecies.size():
		indecies[i] = i
	indecies.sort_custom(func(a,b):
		if fracs[a] == fracs[b]:
			return enemy_types[a].name < enemy_types[b].name
		return fracs[a] > fracs[b]
	)
	print("[Spawner] remainder=", remainder, " indecies(by frac desc)=", indecies)

	for i in range(remainder):
		floors[indecies[i % indecies.size()]] += 1
	print("[Spawner] floors(final)=", floors)

	_spawn_bag.clear()
	for i in enemy_types.size():
		for j in floors[i]:
			_spawn_bag.append(enemy_types[i])
	print("[Spawner] spawn_bag size(before shuffle)=", _spawn_bag.size())

	_spawn_bag.shuffle()

	_remaining_to_spawn = _spawn_bag.size()
	_alive = 0
	_killed = 0
	print("[Spawner] Wave prepared. _remaining_to_spawn=", _remaining_to_spawn, " _alive=", _alive, " _killed=", _killed)
	_wave_prepared = true

func _try_spawn_tick():
	if _remaining_to_spawn <= 0:
		print("[Spawner] Nothing to spawn: _remaining_to_spawn=", _remaining_to_spawn, " spawn_bag size=", _spawn_bag.size(), " (Did you call _prepare_wave()?)")
		return
	if _alive >= concurrent_cap:
		print("[Spawner] Concurrency cap reached: alive=", _alive, " cap=", concurrent_cap)
		return
	
	var pt := _pick_spawn_point()
	if pt == null:
		print("[Spawner] No valid spawn point returned by _pick_spawn_point()")
		return

	var enemy_type: EnemyType = _spawn_bag[_spawn_bag.size() - _remaining_to_spawn]
	print("[Spawner] Spawning enemy type=", enemy_type, " remaining_before=", _remaining_to_spawn)
	var inst: Node3D = enemy_type.scene.instantiate()
	if inst == null:
		print("[Spawner] Failed to instantiate scene for type=", enemy_type)
		return
	self.add_child(inst)
	inst.global_position = pt.global_position
	print("[Spawner] Spawned at point name=", pt.name, " pos=", pt.global_position)

	if inst.has_signal("died"):
		inst.died.connect(_on_enemy_died)
		print("[Spawner] Connected 'died' signal for ", enemy_type)
	else:
		print("[Spawner] Instance has no 'died' signal: ", enemy_type)
	
	_alive += 1
	_remaining_to_spawn -= 1
	print("[Spawner] Post-spawn: alive=", _alive, " remaining_to_spawn=", _remaining_to_spawn, " killed=", _killed)

func _pick_spawn_point() -> Marker3D:
	if spawn_points.is_empty():
		print("[Spawner] _pick_spawn_point: spawn_points is empty")
		return null
	var idx := _rng.randi() % spawn_points.size()
	var sel := spawn_points[idx]
	print("[Spawner] Picked spawn point idx=", idx, " name=", sel.name)
	return sel

func _on_enemy_died():
	_alive = max(0, _alive - 1)
	_killed += 1
	print("[Spawner] Enemy died. alive=", _alive, " killed=", _killed, "/", total_kills)
	if _killed >= total_kills:
		_wave_prepared = false
