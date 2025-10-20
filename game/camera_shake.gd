extends Camera2D
class_name CameraWithShake

@export var max_offset: Vector2 = Vector2(10, 10)
@export var max_offset_k: Vector2 = Vector2(5.0, 5.0)
@export var max_shake_rotation: float = 10.0
@export var max_shake_rotation_k: float = 5.0
#@export var shake_noise: Noise
@export var decay: float = 5.0
@export var damp: float = 0.1
@export var shake_multiplier: float = 3

var shake_offset: Vector2 = Vector2.ZERO
var shake_offset_velocity: Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if shake_offset_velocity.length() > 0.01 or shake_offset.length() > 0.01:
		var acc := -decay * shake_offset - damp * shake_offset_velocity
		shake_offset_velocity += acc * delta
		shake_offset += shake_offset_velocity * delta
		var shake_rotation = shake_offset.x

		var clamped_offset_x = asymptotic_function(shake_offset.x, max_offset.x, max_offset_k.x)
		var clamped_offset_y = asymptotic_function(shake_offset.y, max_offset.y, max_offset_k.y)
		var clamped_rotation = asymptotic_function(shake_rotation, max_shake_rotation, max_shake_rotation_k)

		offset = Vector2(clamped_offset_x, clamped_offset_y)
		rotation_degrees = clamped_rotation
	else:
		shake_offset = Vector2.ZERO
		shake_offset_velocity = Vector2.ZERO
		offset = Vector2.ZERO
		rotation_degrees = 0.0

func asymptotic_function(value: float, max_value: float, k: float) -> float:
	# var signasf = 1.0 if value >= 0.0 else -1.0
	# value = abs(value)
	# return (max_value - (max_value * exp(-k * value))) * signasf
	return value

func shake(direction: Vector2) -> void:
	shake_offset_velocity += direction * shake_multiplier
