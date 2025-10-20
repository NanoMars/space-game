extends Control

@export var texts: Array[TextDefinition] = []
@export var label_to_write: Label
@export var buttons: Array[Button] = []
@export var button_container: HBoxContainer
@export_file("*.tscn") var game_scene: String
@export_file("*.tscn") var main_menu_scene: String
var ctx: Dictionary[String, int] = {}
var _left_click_was_pressed: bool = false
@export var talk1: AudioStreamPlayer
@export var talk2: AudioStreamPlayer

func _ready() -> void:
	ctx["Score"] = ScoreManager.score
	ctx["Round"] = ScoreManager.currentRound
	label_to_write.position = Vector2(138.5, 100)
	for b in buttons:
		var sm := b.material as ShaderMaterial
		if sm:
			sm.set_shader_parameter("opacity", 0.0)
	await animate_text()
	await animate_buttons()
	buttons[0].grab_focus()
	if Settings.get("demo mode") == false:
			Settings.set("tutorial enabled", false)

	await get_tree().create_timer(15.0).timeout
	ScoreManager.reset()
	SceneManager.change_scene(main_menu_scene, {"transition": "fade"})



	
func animate_buttons() -> void:
	var fade_in_tween = get_tree().create_tween().set_parallel(true)

	for b in buttons:

		var sm := b.material as ShaderMaterial
		if sm:
			fade_in_tween.tween_method(
				func(v): sm.set_shader_parameter("opacity", v),
				0.0, 1.0, 1.0
			)
	
	var label_tween = get_tree().create_tween()
	label_tween.tween_property(label_to_write, "position", Vector2(0, -10), 1.0).as_relative()

	var container_tween = get_tree().create_tween()
	container_tween.tween_property(button_container, "position", Vector2(0, -10), 1.0).as_relative()
	await fade_in_tween.finished
	await label_tween.finished
	await container_tween.finished

func wait_or_skip(seconds: float) -> bool:
	# Returns true if "shoot" was pressed during the wait.
	var time_left := seconds
	while time_left > 0.0:
		await get_tree().process_frame
		var left_down := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var left_just_pressed := left_down and not _left_click_was_pressed
		_left_click_was_pressed = left_down
		if Input.is_action_just_pressed("shoot") or left_just_pressed:
			return true
		time_left -= get_process_delta_time()
	_left_click_was_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	return false

func animate_text() -> void:
	# Removed Timer; we now poll each frame so we can skip instantly.
	for t in texts:
		var label_text = t.text.format(ctx)
		label_to_write.visible_characters = 0
		label_to_write.text = label_text

		var goal_characters := label_text.length()
		var char_time_in := t.write_in_time / float(goal_characters)
		var char_time_out := t.write_out_time / float(goal_characters)

		# Type-in animation (skip completes the line instantly)
		for i in range(goal_characters + 1):
			label_to_write.visible_characters = i
			talk1.play()
			if await wait_or_skip(char_time_in):
				label_to_write.visible_characters = goal_characters
				break

		# If not the last text, wait, then type-out (each skippable)
		if t != texts[-1]:
			# Inter-line wait (skip advances immediately)
			await wait_or_skip(t.wait_time)

			# Type-out animation (skip clears the line instantly)
			for i in range(goal_characters, -1, -1):
				label_to_write.visible_characters = i
				talk2.play()
				if await wait_or_skip(char_time_out):
					label_to_write.visible_characters = 0
					break


func _on_try_again_pressed() -> void:
	ScoreManager.reset()
	SceneManager.change_scene(game_scene, {"transition": "fade"})


func _on_give_up_pressed() -> void:
	ScoreManager.reset()
	SceneManager.change_scene(main_menu_scene, {"transition": "fade"})
