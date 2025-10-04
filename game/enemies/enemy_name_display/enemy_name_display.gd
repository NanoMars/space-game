extends "res://game/UI/Tutorial/ui_follow.gd"

@export var lifespan: float = 2.0
@export var enemy_name: String = "enemy"
@export var label: Label = null
@export var animation_player: AnimationPlayer = null

func _ready() -> void:
	super._ready()
	label.text = enemy_name
	
	animation_player.play("spawn")
	await animation_player.animation_finished

	var timer: Timer = Timer.new()
	timer.wait_time = lifespan
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout

	animation_player.play("despawn")
	await animation_player.animation_finished

	queue_free()
