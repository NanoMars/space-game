extends Camera2D
class_name CameraWithShake

@export var max_offset: Vector2 = Vector2(10, 10)
@export var max_offset_k: Vector2 = Vector2(5.0, 5.0)
@export var max_shake_rotation: float = 10.0
@export var max_shake_rotation_k: float = 5.0
@export var shake_noise: Noise
@export var decay: float = 5.0


var shake_amount: float = 0.0
var initial_offset: Vector2
var initial_rotation: float
var time: float = 0.0


func _ready() -> void:
	initial_offset = position
	initial_rotation = rotation


func _physics_process(delta: float) -> void:
	
	if shake_amount > 0.0:
		
		shake_amount = max(shake_amount - decay * delta, 0.0)
		time += delta * shake_amount
		var noise_x: float = shake_noise.get_noise_3d(time, 0.0, 0.0)
		var noise_y: float = shake_noise.get_noise_3d(0.0, time, 0.0)
		var noise_rot: float = shake_noise.get_noise_3d(0.0, 0.0, time)

		offset = Vector2(
			asymptotic_function(noise_x * shake_amount, max_offset.x, max_offset_k.x),
			asymptotic_function(noise_y * shake_amount, max_offset.y, max_offset_k.y)
		)

		rotation_degrees = asymptotic_function(noise_rot * shake_amount, max_shake_rotation, max_shake_rotation_k)

		print("shake_amount: ", shake_amount)

	else:
		position = initial_offset
		rotation = initial_rotation
func asymptotic_function(value: float, max_value: float, k: float) -> float:
	var signasf = 1.0 if value >= 0.0 else -1.0
	value = abs(value)
	return (max_value - (max_value * exp(-k * value))) * signasf

func shake(amount: float) -> void:
	shake_amount += amount
