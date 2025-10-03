extends Button
class_name WeaponDisplay

@export var weapon: Weapon
@export var camera: Camera2D

@export var weapon_stats: WeaponStats:
	set(value):
		print("Setting weapon stats to: %s" % value)
		if weapon:
			weapon.weapon_stats = value
		_weapon_stats = value
		print("Weapon stats now: ", value, "got: ", weapon_stats, " _weapon_stats: ", _weapon_stats)
	get:
		return _weapon_stats

var _weapon_stats: WeaponStats
var id = 0

func _ready() -> void:
	weapon.firing = true

func _on_mouse_entered() -> void:
	grab_focus()
