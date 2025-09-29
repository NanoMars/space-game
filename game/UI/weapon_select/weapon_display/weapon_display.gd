extends Button
class_name WeaponDisplay

@export var weapon: Weapon
@export var weapon_stats: WeaponStats:
	set(value):
		if weapon:
			weapon.weapon_stats = value
	get:
		if weapon:
			return weapon.weapon_stats.value
		return null
	
@export var viewport: SubViewport

func _ready() -> void:
	await get_tree().process_frame
	icon = viewport.get_texture()

func _on_focus_exited() -> void:
	weapon.firing = false


func _on_focus_entered() -> void:
	weapon.firing = true

func _on_mouse_entered() -> void:
	grab_focus()
