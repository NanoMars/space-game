extends Control

@export var weapons: Array[WeaponStats] = []
@export var weapon_display_container: Container
@export var weapon_display_scene: PackedScene
@export var main_menu: PackedScene
@export_file("*.tscn") var game_scene: String

var selected_weapon: WeaponStats = null

func _ready() -> void:
	var id = 0
	for weapon in weapons:
		id += 1
		var display := weapon_display_scene.instantiate()
		display.id = id
		display.weapon_stats = weapon
		weapon_display_container.add_child(display)
		display.pressed.connect(_on_weapon_display_pressed.bind(display))
	weapon_display_container.get_children()[0].grab_focus()



func _on_return_button_pressed() -> void:
	SceneManager.change_scene(main_menu)

func _on_weapon_display_pressed(weapon_display: WeaponDisplay) -> void:
	#Settings.set("selected weapon", weapon_display.weapon_stats.name)
	weapon_display.button_pressed = true
	for child in weapon_display_container.get_children():
		if child != weapon_display:
			child.button_pressed = false
	
	ScoreManager.player_weapon = weapon_display.weapon_stats
	SceneManager.change_scene(game_scene)
	ScoreManager.reset()
