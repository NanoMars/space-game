extends Sprite3D
@export var enemy_arrow: PackedScene
@export var arrow_container: Node2D
var enemies_off_screen: Dictionary[Node, Node] = {}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Add arrows for enemies that just went off-screen
	for n in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(n) or not (n is Node3D):
			continue
		var enemy := n as Node3D
		if is_off_screen(enemy) and not enemies_off_screen.has(enemy):
			var arrow_instance: Node2D = enemy_arrow.instantiate()
			arrow_container.add_child(arrow_instance)
			enemies_off_screen[enemy] = arrow_instance
			enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))

	# Update and cleanup
	var to_remove: Array = []
	for enemy in enemies_off_screen.keys():
		if not is_instance_valid(enemy):
			enemies_off_screen[enemy].queue_free()
			to_remove.append(enemy)
			continue

		var e := enemy as Node3D
		if not is_off_screen(e):
			enemies_off_screen[e].queue_free()
			to_remove.append(e)
		else:
			var arrow: Node2D = enemies_off_screen[e]
			var dir3d: Vector3 = (e.global_position - global_position).normalized()
			var dir: Vector2 = Vector2(dir3d.x, dir3d.z).normalized()
			arrow.rotation = dir.angle() + deg_to_rad(90)

	for enemy in to_remove:
		enemies_off_screen.erase(enemy)

func _on_enemy_tree_exited(enemy: Node) -> void:
	if enemies_off_screen.has(enemy):
		enemies_off_screen[enemy].queue_free()
		enemies_off_screen.erase(enemy)

func is_off_screen(enemy: Node3D) -> bool:
	var gp := enemy.global_position
	if gp.z > 4.8 or gp.z < -4.8:
		return true
	if gp.x > 8.0 or gp.x < -8.0:
		return true
	return false
