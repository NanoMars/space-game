extends MeshInstance3D

@export var horizontal_angle: float = 15.0
@export var vertical_angle: float = 5.0
@export var angle_speed: float = 5.0
var angle_velocity: Vector2 = Vector2.ZERO
var target_angle: Vector2 = Vector2.ZERO
@export var dampening: float = 0.95


func _physics_process(delta: float) -> void:
	var parent = get_parent()
	var parent_velocity = Vector2.ZERO
	if parent and parent is CharacterBody3D:
		parent_velocity = Vector2(parent.velocity.z, parent.velocity.x).normalized()
		target_angle = Vector2(-parent_velocity.x * horizontal_angle, parent_velocity.y * vertical_angle)
		var vec2_rotation = Vector2(rotation_degrees.x, rotation_degrees.z)

		angle_velocity += (target_angle - vec2_rotation) * angle_speed * delta
		# Dampen angular velocity to smooth and prevent overshoot/jitter
		angle_velocity -= (angle_velocity - (dampening * angle_velocity)) * delta


		var vec3_rotation = Vector3(vec2_rotation.x, 180, vec2_rotation.y) + Vector3(angle_velocity.x, 0, angle_velocity.y) * delta
		rotation_degrees = vec3_rotation
