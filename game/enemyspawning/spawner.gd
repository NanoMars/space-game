extends Node
class_name Spawner

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

signal enemies_left(value: int)

func _ready() -> void:
	_rng.randomize()
	if auto_prepare_on_ready:
		_prepare_wave()

func _process(delta: float) -> void:
	# Auto-prepare once as a fallback if not prepared and data is present
	if not _wave_prepared and not enemy_types.is_empty() and not spawn_points.is_empty():
		_prepare_wave()
	if _killed >= total_kills:
		_wave_prepared = false
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_try_spawn_tick()
		_next_delay = lerp(min_spawn_delay, max_spawn_delay, _rng.randf())
		_spawn_timer = _next_delay

func _prepare_wave():
	if enemy_types.is_empty():
		return

	var sum_w := 0.0
	for t in enemy_types:
		sum_w += max(t.weight, 0.0)

	var ideals: Array[float] = []
	for t in enemy_types:
		var w = max(t.weight, 0.0)
		ideals.append(w / sum_w * float(total_kills))

	var floors: Array[int] = []
	var fracs: Array[float] = []
	var used := 0
	for v in ideals:
		var f = int(floor(v))
		floors.append(f)
		fracs.append(v - float(f))
		used += f

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

	for i in range(remainder):
		floors[indecies[i % indecies.size()]] += 1

	_spawn_bag.clear()
	for i in enemy_types.size():
		for j in floors[i]:
			_spawn_bag.append(enemy_types[i])

	_spawn_bag.shuffle()

	_remaining_to_spawn = _spawn_bag.size()
	_alive = 0
	_killed = 0
	_wave_prepared = true

func _try_spawn_tick():
	if _remaining_to_spawn <= 0:
		return
	if _alive >= concurrent_cap:
		return
	
	var pt := _pick_spawn_point()
	if pt == null:
		return

	var enemy_type: EnemyType = _spawn_bag[_spawn_bag.size() - _remaining_to_spawn]
	var inst: Node3D = enemy_type.scene.instantiate()
	if inst == null:
		return
	self.add_child(inst)
	inst.global_position = pt.global_position

	
	inst.tree_exited.connect(_on_enemy_died)
	
	_alive += 1
	_remaining_to_spawn -= 1

func _pick_spawn_point() -> Marker3D:
	if spawn_points.is_empty():
		return null
	var idx := _rng.randi() % spawn_points.size()
	var sel := spawn_points[idx]
	return sel

func _on_enemy_died():
	print("[Spawner] _on_enemy_died called")
	_alive = max(0, _alive - 1)
	_killed += 1
	print("[Spawner] Enemy died. alive=", _alive, " killed=", _killed, "/", total_kills)
	enemies_left.emit(total_kills - _killed)
	if _killed >= total_kills:
		_wave_prepared = false
