extends VBoxContainer
@export var mod_list: Array[Modifier] = []
@export var button_theme: Theme
@export var button_count: int = 3


func _ready() -> void:
	for i in button_count:
		var button := Button.new()
		var mod: Modifier = mod_list.pick_random()
		button.text = mod.display_name + " + X" + str(mod.score_multiplier)
		button.pressed.connect(_on_mod_button_pressed.bind(mod, button))
		button.theme = button_theme
		button.use_parent_material = true
		add_child(button)

func _on_mod_button_pressed(mod: Modifier, _button: Button) -> void:
	if ScoreManager.active_modifiers.has(mod):
		if mod.stackable and mod.stacks < mod.max_stacks:
			mod.stacks += 1
	else:
		ScoreManager.active_modifiers.append(mod)
		ScoreManager.score_multiplier += mod.score_multiplier

	if mod.enemy_to_spawn != null:
		var target_scene := mod.enemy_to_spawn.scene
		var existing: EnemyType = null
		for et in ScoreManager.enemy_types:
			if et.scene == target_scene:
				existing = et
				break
		if existing:
			existing.weight += mod.enemy_to_spawn.weight
		else:
			ScoreManager.enemy_types.append(mod.enemy_to_spawn)

	# always increase difficulty when picking a modifier
	ScoreManager.total_kills = ScoreManager.total_kills * 1.5
	ScoreManager.concurrent_cap = int(ScoreManager.concurrent_cap * 1.5)
	print("Active modifiers: ", ScoreManager.active_modifiers)
