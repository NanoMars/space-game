extends Control

@export var weapons: Array[WeaponStats] = []
@export var weapon_display_container: Container
@export var weapon_display_scene: PackedScene

func _ready() -> void:
	for weapon in weapons:
		var display := weapon_display_scene.instantiate()
		display.weapon_stats = weapon
		weapon_display_container.add_child(display)
