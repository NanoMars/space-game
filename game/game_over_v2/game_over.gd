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

@export_group("sounds")
@export var tick_sound: AudioStreamPlayer
@export var small_event_sound: AudioStreamPlayer
@export var large_event_sound: AudioStreamPlayer

@export var leagues: Dictionary[int, String] = {}
@onready var score: int = ScoreManager.score

var time: float = 0	

var last_tick_score: int = 0
var last_small_event_score: int = 0
var last_large_event_score: int = 0

func _ready() -> void:
	score = 35000

func _process(delta: float) -> void:
	time += delta
	var progress = clamp(time / score_animation_time_sec, 0.0, 1.0)
	var curve_value: float = score_value_curve.sample(progress)
	var calculated_score = int(curve_value * score)
	score_label.text = str(calculated_score)
	if calculated_score - last_tick_score >= tick_every_x_points:
		tick_sound.play()
		last_tick_score = calculated_score
		print("Tick sound played")
	if calculated_score - last_small_event_score >= small_event_every_x_points:
		small_event_sound.play()
		last_small_event_score = calculated_score
		print("Small event sound played")
	if calculated_score - last_large_event_score >= large_event_every_x_points:
		large_event_sound.play()
		last_large_event_score = calculated_score
		print("Large event sound played")
	
	var calculated_font_size = lerp(score_label_small_font_size, score_label_large_font_size, progress)
	score_label.add_theme_font_size_override("font_size", int(calculated_font_size))
