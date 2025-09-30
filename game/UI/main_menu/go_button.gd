extends Button

@export var go_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if go_scene:
		SceneManager.change_scene(go_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
