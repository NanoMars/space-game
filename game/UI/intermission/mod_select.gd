extends VBoxContainer
@export var mod_list: Array[Modifier] = []
@export var upgrade_list: Array[Modifier] = []
@export var button_theme: Theme
@export var button_count: int = 3
@export var mult_label: Label

func _ready() -> void:
	var available_mods: Array[Modifier] = []
	for mod in mod_list:
		if not mod.stackable and ScoreManager.active_modifiers.has(mod):
			continue
		if mod.stackable and ScoreManager.active_modifiers.has(mod) and mod.stacks >= mod.max_stacks:
			continue
		available_mods.append(mod)
	var available_upgrades: Array[Modifier] = []
	for mod in upgrade_list:
		if not mod.stackable and ScoreManager.active_modifiers.has(mod):
			continue
		if mod.stackable and ScoreManager.active_modifiers.has(mod) and mod.stacks >= mod.max_stacks:
			continue
		available_upgrades.append(mod)
	
	available_mods.shuffle()
	for i in range(min(button_count, available_mods.size())):
		var mod: Modifier = available_mods[i]
		add_modifier_button(mod)
	# if available_upgrades.size() > 0:
	# 	available_upgrades.shuffle()
	# 	var upgrade: Modifier = available_upgrades[0]
	# 	add_modifier_button(upgrade)

func add_modifier_button(mod: Modifier) -> void:
	
		
	var button := Button.new()
	
	var text := "%s %s" % [mod.display_name, _format_multiplier(mod.score_multiplier)]
	if ScoreManager.active_modifiers.has(mod):
		text += " (" + str(mod.stacks) + "/" + str(mod.max_stacks) + ")"
	if mod.score_multiplier + ScoreManager.score_multiplier < 0.0:
		button.disabled = true
		text += " too expensive!"
	button.text = text
	button.pressed.connect(_on_mod_button_pressed.bind(mod, button))
	button.mouse_entered.connect(_on_mod_button_mouse_entered.bind(mod, button))
	button.mouse_exited.connect(_on_mod_button_mouse_exited.bind(mod))
	button.theme = button_theme
	button.use_parent_material = true
	add_child(button)

func _format_multiplier(delta: float) -> String:
	if is_zero_approx(delta):
		return "+ X0"
	var sign_text := "+" if delta > 0.0 else "-"
	return "%s X%s" % [sign_text, str(absf(delta))]

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
	ScoreManager.total_kills = int(ScoreManager.total_kills * 1.5)
	ScoreManager.concurrent_cap = int(ScoreManager.concurrent_cap * 1.5)

func _on_mod_button_mouse_entered(mod: Modifier, button: Button) -> void:
	button.grab_focus()
	mult_label.text = "%s %s" % ["X" + str(ScoreManager.score_multiplier), _format_multiplier(mod.score_multiplier)]

func _on_mod_button_mouse_exited(_mod: Modifier) -> void:
	mult_label.text = "X" + str(ScoreManager.score_multiplier)
