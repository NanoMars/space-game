extends Camera3D


func _ready() -> void:
	for node in get_tree().get_nodes_in_group("camera"):
		if node != self:
			node.remove_from_group("camera")
			print("Removed extra camera: ", node)
