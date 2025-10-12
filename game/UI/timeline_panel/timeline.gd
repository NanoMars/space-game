extends Panel
@export var rounds_to_display: int = 5
@export_group("References")
@export var upgrade_scene: PackedScene
@export var downgrade_scene: PackedScene
@export var round_scene: PackedScene
@export var timeline_container: HBoxContainer

func _ready() -> void:
	ScoreManager.on_round_complete.connect(_on_next_round)

	var rounds: Array = []
	if ScoreManager.rounds.is_empty():
		return

	
	var prev_count := int(ceil(float(rounds_to_display) / 2.0))
	var future_count := int(floor(float(rounds_to_display) / 2.0))
	var previous_rounds = ScoreManager.previous_rounds.slice(-prev_count)
	var future_rounds = ScoreManager.rounds.slice(0, future_count)
	rounds = previous_rounds + future_rounds

	for round_type in rounds:
		var inst := _instantiate_round(round_type)
		if inst:
			timeline_container.add_child(inst)
			inst.custom_minimum_size.x = timeline_container.size.x / rounds_to_display

func _on_next_round() -> void:
	var nr = ScoreManager.previous_rounds[-1]
	var inst: Control
	match nr:
		#ScoreManager.round_types.Upgrade:
		#	inst = upgrade_scene.instantiate()

		ScoreManager.round_types.Downgrade:
			inst = downgrade_scene.instantiate()
		ScoreManager.round_types.Round:
			inst = round_scene.instantiate()
	timeline_container.add_child(inst)
	inst.custom_minimum_size.x = timeline_container.size.x / rounds_to_display
	if timeline_container.get_child_count() > rounds_to_display:
		timeline_container.get_child(0).queue_free()

func _instantiate_round(round_type) -> Control:
	var inst: Control
	match round_type:
		ScoreManager.round_types.Downgrade:
			inst = downgrade_scene.instantiate()
		ScoreManager.round_types.Round:
			inst = round_scene.instantiate()
		# ScoreManager.round_types.Upgrade:
		# 	inst = upgrade_scene.instantiate()
	return inst
