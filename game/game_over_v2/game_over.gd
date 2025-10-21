extends Control

@export var score_value_curve: Curve
@export var score_time_multiplier: float = 0.001
@export var small_particles_every_x_points: int = 1000
@export var large_particles_every_x_points: int = 10000

@export var leagues: Dictionary[int, String] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
