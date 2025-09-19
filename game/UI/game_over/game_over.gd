extends Control

@export var texts: Array[TextDefinition] = []
@export var label_to_write: Label

func _ready() -> void:
	await animate_text()
	print("Game over text animation finished.")

func animate_text() -> void:
	var timer: Timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	for t in texts:
		label_to_write.visible_characters = 0
		label_to_write.text = t.text
		var goal_characters = t.text.length()
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
