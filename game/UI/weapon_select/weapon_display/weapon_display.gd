extends Button
class_name WeaponDisplay

@export var weapon: Weapon
@export var camera: Camera3D

@export var weapon_stats: WeaponStats:
	set(value):
		if weapon:
			weapon.weapon_stats = value
	get:
		if weapon:
			return weapon.weapon_stats.value
		return null
var id = 0

func _ready() -> void:
	camera.position.x = 100 * id
	weapon.position.x = 100 * id

func _on_focus_exited() -> void:
	weapon.firing = false


func _on_focus_entered() -> void:
	weapon.firing = true

func _on_mouse_entered() -> void:
	grab_focus()
