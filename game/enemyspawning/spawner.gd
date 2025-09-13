extends Node
class_name Spawner

@export var min_spawn_delay: float = 1.0
@export var max_spawn_delay: float = 5.0
@export var spawn_points: Array[Marker3D] = []
@export var auto_prepare_on_ready: bool = true
@export var intermission: PackedScene
@export var debug_label: Label

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

signal enemies_left(value: int)
signal enemy_died(transform: Transform3D)
signal enemy_spawned(enemy: Node)

func _ready() -> void:
	_rng.randomize()
	if auto_prepare_on_ready:
		_prepare_wave()
	
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_on_start_run)

func _on_start_run() -> void:
	run_started = true
	for mod in ScoreManager.active_modifiers:
		var game_root = get_tree().get_first_node_in_group("game_root") as Node3D
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
	_wave_prepared = true

func _try_spawn_tick():
	if not run_started:
		return
	if _enemies_spawned >= ScoreManager.total_kills:
		return
	if _remaining_to_spawn <= 0:
		return
	if _alive >= ScoreManager.concurrent_cap:
		return
	


	_enemies_spawned += 1
	var pt := _pick_spawn_point()
	if pt == null:
		return

	var enemy_type: EnemyType = _spawn_bag[_spawn_bag.size() - _remaining_to_spawn]
	var inst: Node3D = enemy_type.scene.instantiate()
	if inst == null:
		return
	self.add_child(inst)
	inst.global_position = pt.global_position
	enemy_spawned.emit(inst)
	
	inst.tree_exited.connect(_on_enemy_died.bind(inst.global_transform))
	
	_alive += 1
	_remaining_to_spawn -= 1

func _pick_spawn_point() -> Marker3D:
	if spawn_points.is_empty():
		return null
	var idx := _rng.randi() % spawn_points.size()
	var sel := spawn_points[idx]
	return sel

func _on_enemy_died(transform: Transform3D) -> void:
	_alive = max(0, _alive - 1)
	_killed += 1
	enemies_left.emit(_enemies_left)
	enemy_died.emit(transform)
	if _killed >= ScoreManager.total_kills:
		_wave_prepared = false
	debug_label.text = "Enemies left: " + str(_enemies_left)
	if _enemies_left <= 0:
		debug_label.text = "All enemies defeated! Transitioning..."
		change_scene_to_intermission()

func change_scene_to_intermission() -> void:
	debug_label.text = "Changing scene to intermission..."
	if _changing_scenes:
		debug_label.text = "Already changing scenes, aborting..."
		return
	debug_label.text = "Playing sound and changing scene..."
	_changing_scenes = true
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	debug_label.text = "Changing scene now..."
	get_tree().change_scene_to_packed(intermission)
	debug_label.text = "Scene changed."
	debug_label.text = "Playing sound and changing scene..."
	_changing_scenes = true
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	debug_label.text = "Changing scene now..."
	get_tree().change_scene_to_packed(intermission)
	debug_label.text = "Scene changed."
