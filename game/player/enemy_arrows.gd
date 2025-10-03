extends Sprite2D

@export var enemy_arrow: PackedScene
@export var arrow_container: Node2D

var enemies_off_screen: Dictionary[Node, Node] = {}


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Add arrows for enemies that just went off-screen
	for n in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(n) or not (n is Node2D):
			continue
		var enemy := n as Node2D
		if is_off_screen(enemy) and not enemies_off_screen.has(enemy):
			spawn_arrow_for_enemy(enemy)

	# Update and cleanup
	var to_remove: Array[Node2D] = []
	for enemy in enemies_off_screen.keys():
		if not is_instance_valid(enemy):
			to_remove.append(enemy)
			continue

		var e := enemy as Node2D
		if not is_off_screen(e):
			to_remove.append(e)
		else:
			var arrow: Node2D = enemies_off_screen[e]
			var dir: Vector2 = (e.global_position - global_position).normalized()
			# Adjust +90 degrees if your arrow sprite faces a different default direction.
			arrow.rotation = dir.angle() + deg_to_rad(90)

	for enemy in to_remove:
		despawn_arrow_for_enemy(enemy)

func _on_enemy_tree_exited(enemy: Node) -> void:
	var e := enemy as Node2D
	if e:
		despawn_arrow_for_enemy(e)

func world_to_screen(p: Vector2) -> Vector2:
	var vp := get_viewport()
	var cam := vp.get_camera_2d()
	if cam:
		return cam.unproject_position(p)
	# In Godot 4, use the * operator instead of xform()
	return vp.get_canvas_transform() * p

func is_off_screen(enemy: Node2D) -> bool:
	# Project world position to screen space and check visible rect.
	var enemy_pos: Vector2 = enemy.global_position
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	if enemy_pos.x > screen_size.x or enemy_pos.x < 0 or enemy_pos.y > screen_size.y or enemy_pos.y < 0:
		return true
	return false

func spawn_arrow_for_enemy(enemy: Node2D) -> void:
	if not enemies_off_screen.has(enemy):
		var arrow_instance: Node2D = enemy_arrow.instantiate()
		arrow_container.add_child(arrow_instance)
		enemies_off_screen[enemy] = arrow_instance
		enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))
		var animation_player: AnimationPlayer = arrow_instance.get_child(0)
		if animation_player:
			animation_player.play("spawn")

func despawn_arrow_for_enemy(enemy: Node2D) -> void:
	if enemies_off_screen.has(enemy):

		var arrow_instance: Node2D = enemies_off_screen[enemy]
		var animation_player: AnimationPlayer = arrow_instance.get_child(0)
		if animation_player:
			animation_player.play("despawn")
		await animation_player.animation_finished
		arrow_instance.queue_free()
		enemies_off_screen.erase(enemy)
