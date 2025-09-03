@tool
extends TextureRect


@export var noise_speed: Vector3 = Vector3(0, 0, 30)

func _process(delta: float) -> void:
	texture.noise.offset += delta * noise_speed
