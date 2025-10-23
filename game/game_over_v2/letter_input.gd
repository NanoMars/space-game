@tool
extends HBoxContainer
class_name LetterInput

var letter_scene = preload("res://game/UI/letter_select/letter.tscn")
@export var letter_count: int:
	get:
		return get_child_count()
	set(value):
		var current_count = get_child_count()
		print("Setting letter_count from ", current_count, " to ", value)
		if value > current_count:
			for i in range(value - current_count):
				var letter_instance = letter_scene.instantiate()
				add_child(letter_instance)
		elif value < current_count:
			for i in range(current_count - value):
				var to_remove = get_child(current_count - i - 1)
				remove_child(to_remove)
				to_remove.queue_free()
				#remove_child(get_child(get_child_count() - 1)).queue_free()

var value: String:
	get:
		var result := ""
		for letter_node in get_children():
			if letter_node is Letter:
				result += letter_node.character
		return result

