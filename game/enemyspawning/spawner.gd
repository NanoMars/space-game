extends Node
class_name Spawner

@export var min_spawn_delay: float = 1.0
@export var max_spawn_delay: float = 5.0
@export var spawn_points: Array[Marker2D] = []
@export var auto_prepare_on_ready: bool = true
@export var intermission: PackedScene
@export var spooky_riser: AudioStream
# Added: enable/disable debug prints from the editor
@export var debug_spawning: bool = true

var run_started: bool = false
var _alive := 0
var _enemies_spawned: int = 0
var _spawn_bag: Array[EnemyType] = []
var _spawn_timer: float = 0.0
var _next_delay: float = 0.4
var _remaining_to_spawn: int = 0
var _killed: int = 0
var _rng := RandomNumberGenerator.new()
var _wave_prepared := false
var _changing_scenes := false
var _enemies_left: int:
	get:
		return ScoreManager.total_kills - _killed

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D

signal enemies_left(value: int)
signal enemy_died(transform: Transform2D)
signal enemy_spawned(enemy: Node)

# Added: helper for conditional debug logging
func _dbg(msg: String) -> void:
	if debug_spawning:
		print("[Spawner] ", msg)

func _ready() -> void:
	_rng.randomize()
	_dbg("Ready. auto_prepare_on_ready=%s, enemy_types=%d, spawn_points=%d, total_kills=%d, concurrent_cap=%d" % [
		str(auto_prepare_on_ready),
		ScoreManager.enemy_types.size(),
		spawn_points.size(),
		ScoreManager.total_kills,
		ScoreManager.concurrent_cap
	])
	if auto_prepare_on_ready:
		_dbg("Auto preparing wave on ready...")
		_prepare_wave()
	
	if Settings.get("tutorial enabled") == true or Settings.get("demo mode") == true:
		_dbg("Tutorial or demo mode enabled; deferring run start.")
		return
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_start_run)
	_dbg("Scheduled run start in 1.0s.")

func _on_start_run() -> void:
	if run_started:
		_dbg("Run already started; ignoring.")
		return
	run_started = true
	_dbg("Run started. Active modifiers=%d" % [ScoreManager.active_modifiers.size()])
	for mod in ScoreManager.active_modifiers:
		var game_root = get_tree().get_first_node_in_group("game_root") as Node2D
		mod.on_run_start(game_root)

func _process(delta: float) -> void:
	if not run_started:
		return
	# Auto-prepare once as a fallback if not prepared and data is present
	if not _wave_prepared and not ScoreManager.enemy_types.is_empty() and not spawn_points.is_empty():
		_dbg("Wave not prepared but data present; preparing now...")
		_prepare_wave()
	if _killed >= ScoreManager.total_kills:
		_wave_prepared = false
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_dbg("Spawn tick. enemies_spawned=%d, remaining=%d, alive=%d" % [_enemies_spawned, _remaining_to_spawn, _alive])
		_try_spawn_tick()
		_next_delay = lerp(min_spawn_delay, max_spawn_delay, _rng.randf())
		_spawn_timer = _next_delay
		_dbg("Next spawn in %.2fs" % [_next_delay])

func _prepare_wave():
	if ScoreManager.enemy_types.is_empty():
		_dbg("Cannot prepare wave: ScoreManager.enemy_types is empty.")
		return

	var sum_w := 0.0
	for t in ScoreManager.enemy_types:
		sum_w += max(t.weight, 0.0)
	if sum_w <= 0.0:
		_dbg("Warning: enemy type weights sum to 0. Spawns may fail or be unbalanced.")

	var ideals: Array[float] = []
	for t in ScoreManager.enemy_types:
		var w = max(t.weight, 0.0)
		ideals.append(w / sum_w * float(ScoreManager.total_kills))

	var floors: Array[int] = []
	var fracs: Array[float] = []
	var used := 0
	for v in ideals:
		var f = int(floor(v))
		floors.append(f)
		fracs.append(v - float(f))
		used += f

	var remainder := ScoreManager.total_kills - used
	var indecies := []
	indecies.resize(ScoreManager.enemy_types.size())
	for i in indecies.size():
		indecies[i] = i
	indecies.shuffle()

	for i in range(remainder):
		floors[indecies[i % indecies.size()]] += 1

	_spawn_bag.clear()
	for i in ScoreManager.enemy_types.size():
		for j in floors[i]:
			_spawn_bag.append(ScoreManager.enemy_types[i])

	_spawn_bag.shuffle()

	_remaining_to_spawn = _spawn_bag.size()
	_alive = 0
	_killed = 0
	_wave_prepared = true
	_dbg("Prepared wave. spawn_bag=%d, remaining=%d, total_kills=%d, spawn_points=%d" % [
		_spawn_bag.size(), _remaining_to_spawn, ScoreManager.total_kills, spawn_points.size()
	])

func _try_spawn_tick():
	if not run_started:
		_dbg("Skip spawn: run not started.")
		return
	if _enemies_spawned >= ScoreManager.total_kills:
		_dbg("Skip spawn: enemies_spawned(%d) >= total_kills(%d)." % [_enemies_spawned, ScoreManager.total_kills])
		return
	if _remaining_to_spawn <= 0:
		_dbg("Skip spawn: nothing left to spawn. remaining=%d" % [_remaining_to_spawn])
		return
	if _alive >= ScoreManager.concurrent_cap:
		_dbg("Skip spawn: alive(%d) >= concurrent_cap(%d)" % [_alive, ScoreManager.concurrent_cap])
		return
	if spawn_points.is_empty():
		_dbg("Skip spawn: no spawn points configured.")
		return

	var pt := _pick_spawn_point()
	if pt == null:
		_dbg("Skip spawn: _pick_spawn_point returned null (spawn_points=%d)." % [spawn_points.size()])
		return

	var bag_index := _spawn_bag.size() - _remaining_to_spawn
	if bag_index < 0 or bag_index >= _spawn_bag.size():
		_dbg("Skip spawn: invalid bag index %d (bag size=%d, remaining=%d)" % [bag_index, _spawn_bag.size(), _remaining_to_spawn])
		return
	var enemy_type: EnemyType = _spawn_bag[bag_index]
	if enemy_type == null:
		_dbg("Skip spawn: enemy_type at index %d is null." % [bag_index])
		return
	if enemy_type.scene == null:
		_dbg("Skip spawn: enemy_type.scene is null for index %d." % [bag_index])
		return

	var inst: Node2D = enemy_type.scene.instantiate()
	if inst == null:
		_dbg("Skip spawn: instantiate() returned null.")
		return

	_enemies_spawned += 1
	inst.add_to_group("enemies")
	self.add_child(inst)
	inst.global_position = pt.global_position
	enemy_spawned.emit(inst)
	_dbg("Spawned %s at %s. spawned=%d, alive(before inc)=%d, remaining(before dec)=%d" % [
		inst.name, str(pt.global_position), _enemies_spawned, _alive, _remaining_to_spawn
	])
	
	inst.tree_exited.connect(_on_enemy_died.bind(inst.global_transform))
	_alive += 1
	_remaining_to_spawn -= 1
	_dbg("Post-spawn state: alive=%d, remaining=%d" % [_alive, _remaining_to_spawn])

func _pick_spawn_point() -> Marker2D:
	if spawn_points.is_empty():
		_dbg("No spawn points available.")
		return null
	var idx := _rng.randi() % spawn_points.size()
	var sel := spawn_points[idx]
	return sel

func _on_enemy_died(transform: Transform2D) -> void:
	_alive = max(0, _alive - 1)
	_killed += 1
	enemies_left.emit(_enemies_left)
	enemy_died.emit(transform)
	_dbg("Enemy died. alive=%d, killed=%d, enemies_left=%d" % [_alive, _killed, _enemies_left])
	if _killed >= ScoreManager.total_kills:
		_dbg("All required kills achieved. Marking wave unprepared.")
		_wave_prepared = false
	if _enemies_left <= 0:
		_dbg("No enemies left; switching to intermission.")
		change_scene_to_intermission()

func change_scene_to_intermission() -> void:
	# detect if player doesn't exist or is dead
	if not player:
		_dbg("Not changing scene: player not found.")
		return
	if player.dead == true:
		_dbg("Not changing scene: player is dead.")
		return
	if _changing_scenes:
		_dbg("Not changing scene: change already in progress.")
		return
	_changing_scenes = true
	_dbg("Changing scene to intermission with fade.")
	SceneManager.change_scene(intermission, {"transition": "fade"})
