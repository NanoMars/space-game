extends Button
class_name Letter

var focused: bool = false

@onready var highlight: TextureRect = $Highlight
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var character: String:
	get:
		return letters[letter_index]
	set(value):
		if value in letters:
			letter_index = letters.find(value)
var letter_index: int = 0
var letters: Array[String] = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
]

func _on_focus_exited() -> void:
	focused = false
	highlight.visible = false

func _on_focus_entered() -> void:
	focused = true
	highlight.visible = true

func _input(event: InputEvent) -> void:
	if focused:
		if event.is_action_pressed("ui_up"):
			print("Up pressed while focused")
			
			# Add your logic here
			get_viewport().set_input_as_handled()
			_on_up_button_pressed()
		elif event.is_action_pressed("ui_down"):
			print("Down pressed while focused")
			# Add your logic here
			get_viewport().set_input_as_handled()
			_on_down_button_pressed()

func _on_up_button_pressed() -> void:
	animation_player.play("up_pressed")
	grab_focus()
	letter_index = (letter_index - 1 + letters.size()) % letters.size()
	text = character

func _on_down_button_pressed() -> void:
	animation_player.play("down_pressed")
	grab_focus()
	letter_index = (letter_index + 1) % letters.size()
	text = character

