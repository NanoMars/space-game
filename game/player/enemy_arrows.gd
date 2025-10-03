extends Sprite2D

@export var enemy_arrow: PackedScene
@export var arrow_container: Node2D

# Map: enemy_id:int -> { enemy: WeakRef, arrow: Node2D }
var enemies_off_screen: Dictionary = {}

func _key_for(enemy: Object) -> int:
	return enemy.get_instance_id()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Add arrows for enemies that just went off-screen
	for n in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(n) or not (n is Node2D):
			continue
		var enemy := n as Node2D
		if is_off_screen(enemy):
			var id := _key_for(enemy)
			if not enemies_off_screen.has(id):
				spawn_arrow_for_enemy(enemy)

	# Update and cleanup
	var to_remove: Array[int] = []
	for id in enemies_off_screen.keys():
		var entry: Dictionary = enemies_off_screen[id]
		var enemy_ref: WeakRef = entry.get("enemy")
		var enemy: Node2D = enemy_ref.get_ref()
		if enemy == null:
			to_remove.append(id)
			continue

		if not is_off_screen(enemy):
			to_remove.append(id)
		else:
			var arrow: Node2D = entry.get("arrow")
			if is_instance_valid(arrow):
				var dir: Vector2 = (enemy.global_position - global_position).normalized()
				# Adjust +90 degrees if your arrow sprite faces a different default direction.
				arrow.rotation = dir.angle() + deg_to_rad(90)

	for id in to_remove:
		despawn_arrow_by_id(id)

func _on_enemy_tree_exited(id: int) -> void:
	despawn_arrow_by_id(id)

func is_off_screen(enemy: Node2D) -> bool:
	# Project world position to screen space and check visible rect.
	# NOTE: If you use a Camera2D, consider converting to screen coords via the camera.
	var enemy_pos: Vector2 = enemy.global_position
	var screen_size: Vector2 = get_viewport().get_visible_rect().size
	return enemy_pos.x > screen_size.x or enemy_pos.x < 0 or enemy_pos.y > screen_size.y or enemy_pos.y < 0

func spawn_arrow_for_enemy(enemy: Node2D) -> void:
	var id := _key_for(enemy)
	if enemies_off_screen.has(id):
		return

	var arrow_instance: Node2D = enemy_arrow.instantiate()
	arrow_container.add_child(arrow_instance)
	enemies_off_screen[id] = {
		"enemy": weakref(enemy),
		"arrow": arrow_instance
	}

	# Bind the id so we can despawn safely even after the node is freed.
	enemy.tree_exited.connect(_on_enemy_tree_exited.bind(id))

	var animation_player := arrow_instance.get_child(0) as AnimationPlayer
	if animation_player:
		animation_player.play("spawn")

func despawn_arrow_by_id(id: int) -> void:
	if not enemies_off_screen.has(id):
		return

	var entry: Dictionary = enemies_off_screen[id]
	var arrow_instance: Node2D = entry.get("arrow")

	if is_instance_valid(arrow_instance):
		var animation_player := arrow_instance.get_child(0) as AnimationPlayer
		if animation_player:
			animation_player.play("despawn")
			await animation_player.animation_finished
		arrow_instance.queue_free()

	enemies_off_screen.erase(id)
