@tool
extends Node3D
class_name Weapon

@export var firing: bool = false
@export var weapon_stats: WeaponStats
var _time: float = 0.0

func _ready() -> void:
	get_projectile_container()
	if Engine.is_editor_hint():
		return
		

func _process(delta: float) -> void:
	_time += delta

func fire_once() -> void:
	if not weapon_stats:
		return
	
	var directions: Array[Vector3] = weapon_stats.get_directions(_time)
	for dir in directions:
		var projectile_instance: Node3D = weapon_stats.projectile_scene.instantiate()
		add_child(projectile_instance)
		projectile_instance.global_transform = global_transform
		get_projectile_container().add_child(projectile_instance)

func get_projectile_container() -> Node:
	var projectile_parent = get_tree().current_scene.get_node_or_null("Projectiles")
	if not projectile_parent:
		var folder: Node = Node.new()
		folder.name = "Projectiles"
		get_tree().add_child(folder)
		return folder
	else:
		return projectile_parent
