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
var _next_round_triggered := false
var _carryover_enemies: int = 0  # Track enemies from previous round
var _enemies_left: int:
	get:
		# Account for carryover enemies in the total
		return ScoreManager.total_kills - (_killed - _carryover_enemies)

const DEBUG_LOG := false

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D

signal enemies_left(value: int)
signal enemy_died(transform: Transform2D)
signal enemy_spawned(enemy: Node)

func _ready() -> void:
	_rng.randomize()
	if auto_prepare_on_ready:
		_prepare_wave()

	if (Settings.get("tutorial enabled") == true or Settings.get("demo mode") == true) and ScoreManager.keybinds_shown == false:
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
	

func _try_spawn_tick():
	if not run_started:
		return
	if _remaining_to_spawn <= 0:
		return
	if _enemies_spawned >= ScoreManager.total_kills:
		return
	if _alive >= ScoreManager.concurrent_cap:
		return
	if spawn_points.is_empty():
		return

	var pt := _pick_spawn_point()
	if pt == null:
		return

	var bag_index := _spawn_bag.size() - _remaining_to_spawn
	if bag_index < 0 or bag_index >= _spawn_bag.size():
		return
	var enemy_type: EnemyType = _spawn_bag[bag_index]
	if enemy_type == null:
		return
	if enemy_type.scene == null:
		return

	var inst: Node2D = enemy_type.scene.instantiate()
	if inst == null:
		return

	_enemies_spawned += 1
	inst.add_to_group("enemies")
	self.add_child(inst)
	inst.global_position = pt.global_position
	enemy_spawned.emit(inst)
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
	
	# If we have carryover enemies, count this death against them first
	if _carryover_enemies > 0:
		_carryover_enemies -= 1
	
	enemies_left.emit(_enemies_left)
	enemy_died.emit(transform)
	if _killed >= ScoreManager.total_kills:
		_wave_prepared = false
	
	# Prevent triggering next_round multiple times
	if _next_round_triggered:
		return
	
	# Trigger next round early (at 10 enemies) only for non-Downgrade rounds
	# AND only when we've killed enough enemies (not just spawned fewer)
	if _enemies_left <= 10 and _alive <= 10 and ScoreManager.rounds[0] != ScoreManager.round_types.Downgrade:
		print("next round cause enemies left <= 10: ", "Enemies left: ", _enemies_left, " rounds[0]: ", ScoreManager.rounds[0], " downgrade: ", ScoreManager.round_types.Downgrade)
		_next_round_triggered = true
		next_round()
	elif _enemies_left <= 0:
		print("next round cause enemies left <= 0: ", "Enemies left: ", _enemies_left, " rounds[0]: ", ScoreManager.rounds[0], " downgrade: ", ScoreManager.round_types.Downgrade)
		_next_round_triggered = true
		next_round()

func next_round() -> void:
	# detect if player doesn't exist or is dead
	if not _ensure_player_reference():
		return
	if player.dead == true:
		return
	_changing_scenes = true
	ScoreManager.next_round()

func _reset_spawner() -> void:
	# Track how many enemies are still alive from the previous round
	_carryover_enemies = _alive
	
	# If there are enemies still alive, add them to the next round's count
	if _alive > 0:
		ScoreManager.total_kills += _alive
	
	# Reset most spawner state but keep _alive and adjust _killed
	_enemies_spawned = 0
	_killed = 0  # Reset kill counter, carryover enemies will be tracked separately
	_spawn_timer = 0.0
	_next_delay = 0.4
	_wave_prepared = false
	_changing_scenes = false
	_next_round_triggered = false
	
	# Clear any existing spawn bag
	_spawn_bag.clear()
	
	# Prepare the wave again with current settings
	_prepare_wave()
	
	# Add a small delay before spawning resumes
	_spawn_timer = 2.0  # 2 second delay before first spawn after reset


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
