extends Control

@export var score_value_curve: Curve
@export var score_animation_time_sec: float = 8.0

@export var tick_every_x_points: int = 10
@export var small_event_every_x_points: int = 1000
@export var large_event_every_x_points: int = 10000

@export var score_label_small_font_size: float = 16
@export var score_label_large_font_size: float = 24

@export_group("objects")
@export var score_label: Label
@export var final_animations: Array[AnimationPlayer]

@export_group("sounds")
@export var tick_sound: AudioStreamPlayer
@export var small_event_sound: AudioStreamPlayer
@export var large_event_sound: AudioStreamPlayer
@export var final_event_sound: AudioStreamPlayer

@export_group("particles")
@export var large_particles: GPUParticles2D
@export var final_particles: GPUParticles2D

@export var leagues: Dictionary[int, String] = {}
@onready var score: int = ScoreManager.score

@export_group("text shake")
@export var shake_magnitude: Curve
@export var shake_speed: Curve
@export var shake_noise: Noise


var time: float = 0	
var shake_time: float = 0.0

var last_tick_score: int = 0
var last_small_event_score: int = 0
var last_large_event_score: int = 0
var final_event_played: bool = false

@onready var score_label_original_position: Vector2 = score_label.position

func _ready() -> void:
	score = ScoreManager.score

func _process(delta: float) -> void:
	time += delta
	var progress = clamp(time / score_animation_time_sec, 0.0, 1.0)
	var curve_value: float = score_value_curve.sample(progress)
	var calculated_score = int(curve_value * score)
	score_label.text = str(calculated_score)
	if calculated_score - last_tick_score >= tick_every_x_points:
		tick_sound.play()
		last_tick_score = calculated_score
	if calculated_score - last_small_event_score >= small_event_every_x_points:
		small_event_sound.play()
		last_small_event_score = calculated_score
	if calculated_score - last_large_event_score >= large_event_every_x_points:
		large_event_sound.play()
		last_large_event_score = calculated_score
		large_particles.emitting = true

	#print("calculated_score: ", calculated_score, " score: ", score)
	if not final_event_played and calculated_score >= score:
		final_event_sound.play()
		final_particles.emitting = true
		for final_animation in final_animations:
			final_animation.play("animation")
		final_event_played = true
	
	var shake_magnitude_value = shake_magnitude.sample(progress)
	var shake_speed_value = shake_speed.sample(progress)
	shake_time += (delta * shake_speed_value)
	var noise_sample: Vector2 = Vector2(
		shake_noise.get_noise_2d(shake_time, 0.0),
		shake_noise.get_noise_2d(0.0, shake_time)
	)
	score_label.position = score_label_original_position + noise_sample * shake_magnitude_value

	
	var calculated_label_scale = lerp(score_label_small_font_size, score_label_large_font_size, progress)
	score_label.scale = calculated_label_scale * Vector2.ONE
	score_label.pivot_offset = score_label.size * 0.5
