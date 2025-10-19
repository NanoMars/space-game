extends Node
class_name Spawner

@export var min_spawn_delay: float = 0.3  # Reduced from 1.0
@export var max_spawn_delay: float = 2.0  # Reduced from 5.0
@export var spawn_points: Array[Marker2D] = []
@export var auto_prepare_on_ready: bool = true
@export var intermission: PackedScene
@export var spooky_riser: AudioStream
@export var warning_sound: AudioStreamPlayer
@export var spawner_time_seconds: float = 0.001

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

const DEBUG_LOG := false

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D

signal enemies_left(value: int)
signal enemy_died(transform: Transform2D)
signal enemy_spawned(enemy: Node)

func _ready() -> void:
	_rng.randomize()
	if auto_prepare_on_ready:
		_debug("ready", "auto prepare")
		_prepare_wave()

	print("tutorial enabled: ", Settings.get("tutorial enabled") == true, "demo mode: ", Settings.get("demo mode") == true, "keybinds shown: ", ScoreManager.keybinds_shown == true, " ")
	if (Settings.get("tutorial enabled") == true or Settings.get("demo mode") == true) and ScoreManager.keybinds_shown == false:
		print("Delaying run start for tutorial or demo mode")
		return
	var timer := Timer.new()
	timer.wait_time = spawner_time_seconds
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_start_run)
	ScoreManager.reset_spawner.connect(_reset_spawner)

func _on_start_run() -> void:
	if run_started:
		return
	run_started = true
	for mod in ScoreManager.active_modifiers:
		var game_root = get_tree().get_first_node_in_group("game_root") as Node2D
		mod.on_run_start(game_root)

func _process(delta: float) -> void:
	if not run_started:
		return
	# Auto-prepare once as a fallback if not prepared and data is present
	if not _wave_prepared and not ScoreManager.enemy_types.is_empty() and not spawn_points.is_empty():
		_prepare_wave()
	if _killed >= ScoreManager.total_kills:
		_wave_prepared = false
		return
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_try_spawn_tick()
		_next_delay = lerp(min_spawn_delay, max_spawn_delay, _rng.randf())
		_spawn_timer = _next_delay

func _prepare_wave():
	if ScoreManager.enemy_types.is_empty():
		_debug("prepare_wave", "enemy types empty")
		return

	var sum_w := 0.0
	for t in ScoreManager.enemy_types:
		sum_w += max(t.weight, 0.0)
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
	_enemies_spawned = 0
	_wave_prepared = true
	_debug("prepare_wave", "prepared %d enemies" % _remaining_to_spawn)
	

func _try_spawn_tick():
	if not run_started:
		_debug("try_spawn", "run not started")
		return
	if _remaining_to_spawn <= 0:
		_debug("try_spawn", "no remaining to spawn", true)
		return
	if _enemies_spawned >= ScoreManager.total_kills:
		_debug("try_spawn", "spawned >= total", true)
		return
	if _alive >= ScoreManager.concurrent_cap:
		_debug("try_spawn", "alive >= cap", true)
		return
	if spawn_points.is_empty():
		_debug("try_spawn", "no spawn points")
		return

	var pt := _pick_spawn_point()
	if pt == null:
		return

	var bag_index := _spawn_bag.size() - _remaining_to_spawn
	if bag_index < 0 or bag_index >= _spawn_bag.size():
		_debug("try_spawn", "bag index out of range %d" % bag_index, true)
		return
	var enemy_type: EnemyType = _spawn_bag[bag_index]
	if enemy_type == null:
		_debug("try_spawn", "enemy type null", true)
		return
	if enemy_type.scene == null:
		_debug("try_spawn", "enemy scene null", true)
		return

	var inst: Node2D = enemy_type.scene.instantiate()
	if inst == null:
		_debug("try_spawn", "instantiation failed", true)
		return

	_enemies_spawned += 1
	inst.add_to_group("enemies")
	self.add_child(inst)
	inst.global_position = pt.global_position
	enemy_spawned.emit(inst)
	_debug("try_spawn", "spawned %s" % inst.name)
	if warning_sound:
		warning_sound.play()
	
	inst.tree_exited.connect(_on_enemy_died.bind(inst.global_transform))
	_alive += 1
	_remaining_to_spawn -= 1

func _pick_spawn_point() -> Marker2D:
	if spawn_points.is_empty():
		return null
	var idx := _rng.randi() % spawn_points.size()
	var sel := spawn_points[idx]
	return sel

func _on_enemy_died(transform: Transform2D) -> void:
	_alive = max(0, _alive - 1)
	_killed += 1
	enemies_left.emit(_enemies_left)
	enemy_died.emit(transform)
	_debug("enemy_died", "killed=%d left=%d" % [_killed, _enemies_left])
	if _killed >= ScoreManager.total_kills:
		_wave_prepared = false
	if _enemies_left <= 5:
		_debug("enemy_died", "triggering next round")
		next_round()

func next_round() -> void:
	# detect if player doesn't exist or is dead
	if not _ensure_player_reference():
		_debug("next_round", "player missing")
		return
	if player.dead == true:
		_debug("next_round", "player dead")
		return
	_changing_scenes = true
	_debug("next_round", "advancing")
	ScoreManager.next_round()

func _reset_spawner() -> void:
	# Reset all spawner state to beginning of round
	_alive = 0
	_enemies_spawned = 0
	_killed = 0
	_spawn_timer = 0.0
	_next_delay = 0.4
	_wave_prepared = false
	_changing_scenes = false
	_debug("reset", "state cleared")
	
	# Clear any existing spawn bag
	_spawn_bag.clear()
	
	# Prepare the wave again with current settings
	_prepare_wave()
	
	# Add a small delay before spawning resumes
	_spawn_timer = 2.0  # 2 second delay before first spawn after reset
	_debug("reset", "spawn timer delay set to %f" % _spawn_timer)


func _debug(context: String, message: String, include_state: bool = false) -> void:
	if not DEBUG_LOG:
		return
	var state := ""
	if include_state:
		state = " | alive=%d remaining=%d spawned=%d killed=%d total=%d wave_prepared=%s" % [
			_alive,
			_remaining_to_spawn,
			_enemies_spawned,
			_killed,
			ScoreManager.total_kills,
			str(_wave_prepared)
		]
	print("[Spawner][%s] %s%s" % [context, message, state])


func _ensure_player_reference() -> bool:
	if is_instance_valid(player):
		return true
	if not is_inside_tree():
		return false
	var tree := get_tree()
	if tree == null:
		return false
	var found_player := tree.get_first_node_in_group("player")
	if found_player == null:
		return false
	if not (found_player is Node2D):
		return false
	player = found_player as Node2D
	return is_instance_valid(player)
