extends Node3D
class_name Weapon

@export var firing: bool = false
@export var weapon_stats: WeaponStats
var fire_pattern: FirePattern
var _time: float = 0.0

func _ready() -> void:
	call_deferred("get_projectile_container")
	if weapon_stats and weapon_stats.fire_pattern:
		fire_pattern = weapon_stats.fire_pattern

func _process(delta: float) -> void:
	_time += delta

func fire_once() -> void:
	if not weapon_stats:
		return

	var directions: Array[Transform3D] = fire_pattern.get_directions()
	var container := get_projectile_container()
	for dir in directions:
		var projectile_instance: Node3D = weapon_stats.projectile_scene.instantiate()
		projectile_instance.global_transform = global_transform
		container.add_child(projectile_instance)

func get_projectile_container() -> Node:
	var root := get_tree().root
	var projectile_parent := root.get_node_or_null("Projectiles")
	if projectile_parent:
		return projectile_parent
	var folder := Node.new()
	folder.name = "Projectiles"
	root.call_deferred("add_child", folder)
	return folder
