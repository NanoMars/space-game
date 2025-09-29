extends Button
class_name WeaponDisplay

@export var weapon: Weapon
@export var weapon_stats: WeaponStats
	
	
@export var viewport: SubViewport
@export var node3d: PackedScene

func _ready() -> void:
	var sub_viewport = SubViewport.new()
	add_child(sub_viewport)
	viewport = sub_viewport
	var node3d_instance = node3d.instantiate()
	viewport.add_child(node3d_instance)
	weapon = node3d_instance.get_node("Weapon") as Weapon
	weapon.weapon_stats = weapon_stats

	viewport.size = Vector2i(64, 64)  # ensure it isn't 0x0

	viewport.transparent_bg = true
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	await RenderingServer.frame_post_draw   # wait for first render
	icon = viewport.get_texture()           # assign once; it keeps updating

func _on_focus_exited() -> void:
	weapon.firing = false


func _on_focus_entered() -> void:
	weapon.firing = true

func _on_mouse_entered() -> void:
	grab_focus()
