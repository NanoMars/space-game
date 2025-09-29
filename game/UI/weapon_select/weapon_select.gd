extends Control

@export var weapons: Array[WeaponStats] = []
@export var weapon_display_container: Container
@export var weapon_display_scene: PackedScene

func _ready() -> void:
	var id = 0
	for weapon in weapons:
		id += 1
		var display := weapon_display_scene.instantiate()
		display.id = id
		display.weapon_stats = weapon
		weapon_display_container.add_child(display)
