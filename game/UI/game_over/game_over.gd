extends Control

@export var texts: Array[TextDefinition] = []
@export var label_to_write: Label
@export var buttons: Array[Button] = []
@export var button_container: HBoxContainer
@export_file("*.tscn") var game_scene: String
@export_file("*.tscn") var main_menu_scene: String
var ctx: Dictionary[String, int] = {}


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
	print("Finished animating text and buttons")
	buttons[0].grab_focus()



	
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

func animate_text() -> void:
	var timer: Timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	for t in texts:
		var label_text = t.text
		label_text = label_text.format(ctx)
		label_to_write.visible_characters = 0
		label_to_write.text = label_text
		print("label_text: " + label_text)
		var goal_characters = label_text.length()
		var char_time_in = t.write_in_time / float(goal_characters)
		var char_time_out = t.write_out_time / float(goal_characters)

		for i in range(goal_characters + 1):
			SoundManager.play_sound(SoundManager.talk_1)
			label_to_write.visible_characters = i
			timer.wait_time = char_time_in
			timer.start()
			await timer.timeout

		if t != texts[-1]:
			timer.wait_time = t.wait_time
			timer.start()
			await timer.timeout

			for i in range(goal_characters, -1, -1):
				SoundManager.play_sound(SoundManager.talk_2)
				label_to_write.visible_characters = i
				timer.wait_time = char_time_out
				timer.start()
				await timer.timeout


func _on_try_again_pressed() -> void:
	ScoreManager.reset()
	SceneManager.change_scene(game_scene, {"transition": "fade"})


func _on_give_up_pressed() -> void:
	ScoreManager.reset()
	SceneManager.change_scene(main_menu_scene, {"transition": "fade"})
