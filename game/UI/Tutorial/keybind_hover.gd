extends VBoxContainer

@export var flip_time: float = 2.0
@export var keys: Dictionary[KeybindDisplayResource, TextureRect] = {}

@export var spacebar_pressed_texture: Texture2D
@export var spacebar_pressed: bool = false
@export var spacebar_rect: TextureRect

var timer: Timer

var showing_wasd: bool = true
var use_timer: bool = true
var ui_hidden: bool = false

@onready var spawner: Node = get_tree().get_first_node_in_group("spawner")

@export var sprite_2d: Sprite2D

func _ready() -> void:
	if Settings.get("tutorial enabled") == false and Settings.get("demo mode") == false:
		visible = false
		return

	set_process_input(true)

	timer = Timer.new()
	timer.wait_time = flip_time
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)




func _process(_delta):
	if Settings.get("tutorial enabled") == false and Settings.get("demo mode") == false and not spawner.run_started and not ui_hidden:
		sprite_2d.queue_free()

	if Input.is_action_just_pressed("shoot"):
		spacebar_pressed = true
		spacebar_rect.texture = spacebar_pressed_texture

	var all_pressed = true

	for resource in keys.keys():
		var rect = keys[resource]
		if Input.is_action_just_pressed(resource.input_action):
			resource.pressed = true
		rect.texture = resource.wasd_pressed_texture if showing_wasd and resource.pressed else resource.arrow_pressed_texture if not showing_wasd and resource.pressed else resource.wasd_normal_texture if showing_wasd else resource.arrow_normal_texture
		if not resource.pressed:
			all_pressed = false
	if all_pressed and spacebar_pressed:
		ui_hidden = true
		spawner._on_start_run()
		if Settings.get("demo mode") == false:
			Settings.set("tutorial enabled", false)

		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.5)
		await tween.finished
		sprite_2d.queue_free()
		

func _on_timer_timeout() -> void:
	if not use_timer:
		return
	showing_wasd = not showing_wasd



	
		



	
