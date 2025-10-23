extends Button

@export var letter_container: Container
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var container_children = letter_container.get_children()
	var last_letter_node: Button = container_children[container_children.size() - 1]
	last_letter_node.focus_entered.connect(_on_last_letter_focused)
	await get_tree().create_timer(20.0).timeout
	_on_last_letter_focused()

var animation_played: bool = false

func _on_last_letter_focused() -> void:
	if not visible and not animation_played:
		$AnimationPlayer.play("animation")


func _on_pressed() -> void:
	if not animation_played:
		$AnimationPlayer.play("pressed_animation")
		animation_played = true
