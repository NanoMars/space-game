extends CanvasLayer

@export var background_scenes: Dictionary[PackedScene, Curve] = {}

@export_group("Speed Relationships")

@export_group("References")
@export var background: ColorRect


var time_passed: float = 0.0
var speed_curve: Curve


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var current_round: int = ScoreManager.currentRound
	var keys = background_scenes.keys()
	var index: int = (current_round - 1) % keys.size()
	var background_scene: PackedScene = keys[index]
	var background_instance: Node2D = background_scene.instantiate()
	speed_curve = background_scenes[background_scene]
	add_child(background_instance)

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_passed + delta >= speed_curve.max_domain:
		return
	time_passed += delta
	var speed = clamp(speed_curve.sample(clamp(time_passed, speed_curve.min_domain, speed_curve.max_domain)), 0.0, 2.0)
	background.material.set_shader_parameter("speed", (speed / 2) + 0.5)
	var compression = clamp(2 - speed, 0.1, 2.0)
	background.material.set_shader_parameter("compression", compression)
	# var trail_size = -29.41 * speed + 108.82
	# background.material.set_shader_parameter("trail_size", trail_size)

	# var density = clamp(2750 * speed + 500, 500, 6000)
	# background.material.set_shader_parameter("density", density)
