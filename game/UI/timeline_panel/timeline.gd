extends Panel
@export var rounds_to_display: int = 5
@export var animation_time_seconds: float = 0.5
@export_group("References")
@export var upgrade_scene: PackedScene
@export var downgrade_scene: PackedScene
@export var round_scene: PackedScene
@export var timeline_container: HBoxContainer

func _ready() -> void:
	ScoreManager.on_round_complete.connect(_on_next_round)

	if ScoreManager.rounds.is_empty() and ScoreManager.previous_rounds.is_empty():
		return
	_refresh_timeline()

func _on_next_round() -> void:
	var future_count := _get_future_count()
	if future_count <= 0 or ScoreManager.rounds.is_empty():
		_refresh_timeline()
		return
	var target_index: int = clampi(future_count - 1, 0, ScoreManager.rounds.size() - 1)
	var next_future_type = ScoreManager.rounds[target_index]
	var inst: Control = await animate_new_round(next_future_type)
	if inst == null:
		_refresh_timeline()
		return
	timeline_container.add_child(inst)
	inst.custom_minimum_size.x = _get_cell_width()
	if timeline_container.get_child_count() > rounds_to_display:
		var first_child := timeline_container.get_child(0)
		timeline_container.remove_child(first_child)
		first_child.queue_free()

func _instantiate_round(round_type) -> Control:
	var inst: Control
	match round_type:
		ScoreManager.round_types.Downgrade:
			inst = downgrade_scene.instantiate()
		ScoreManager.round_types.Round:
			inst = round_scene.instantiate()
		ScoreManager.round_types.Upgrade:
			inst = upgrade_scene.instantiate()
	return inst

func animate_new_round(round_type) -> Control:
	var inst: Control
	match round_type:
		ScoreManager.round_types.Upgrade:
			inst = upgrade_scene.instantiate()
		ScoreManager.round_types.Downgrade:
			inst = downgrade_scene.instantiate()
		ScoreManager.round_types.Round:
			inst = round_scene.instantiate()
	if inst == null:
		return null
	inst.custom_minimum_size.x = _get_cell_width()
	add_child(inst)
	inst.position = inst.custom_minimum_size * Vector2(rounds_to_display, 0)
	var new_object_tween := create_tween()
	new_object_tween.tween_property(inst, "position", inst.custom_minimum_size * Vector2(rounds_to_display - 1, 0), animation_time_seconds).set_ease(Tween.EASE_OUT)
	var container_tween := create_tween()
	var original_container_pos: Vector2 = timeline_container.position
	container_tween.tween_property(timeline_container, "position", timeline_container.position - inst.custom_minimum_size * Vector2(1, 0), animation_time_seconds).set_ease(Tween.EASE_OUT)
	await container_tween.finished
	timeline_container.position = original_container_pos
	inst.get_parent().remove_child(inst)
	return inst

func _get_previous_count() -> int:
	return int(ceil(float(rounds_to_display) / 2.0))

func _get_future_count() -> int:
	return int(floor(float(rounds_to_display) / 2.0))

func _get_cell_width() -> float:
	var available_width := timeline_container.size.x
	if available_width <= 0:
		available_width = size.x
	if available_width <= 0 or rounds_to_display <= 0:
		return 0.0
	return available_width / float(rounds_to_display)

func _refresh_timeline() -> void:
	for child in timeline_container.get_children():
		timeline_container.remove_child(child)
		child.queue_free()
	var prev_count := _get_previous_count()
	var future_count := _get_future_count()
	var previous_rounds = ScoreManager.previous_rounds.slice(-prev_count)
	var future_rounds = ScoreManager.rounds.slice(0, future_count)
	var rounds: Array = previous_rounds + future_rounds
	for round_type in rounds:
		var inst := _instantiate_round(round_type)
		if inst:
			timeline_container.add_child(inst)
			inst.custom_minimum_size.x = _get_cell_width()
