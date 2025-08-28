# Godot 4.4
extends MeshInstance3D

@export var amplitude: float = 2.0
@export var scroll_speed: float = 0.15
@export var world_scale: Vector2 = Vector2(0.04, 0.04) # bigger = smoother terrain

var material := ShaderMaterial.new()

func _ready():
	# Build a 3D noise texture
	var fn := FastNoiseLite.new()
	fn.noise_type = FastNoiseLite.TYPE_SIMPLEX
	fn.frequency = 0.015
	fn.fractal_type = FastNoiseLite.FRACTAL_FBM
	fn.fractal_octaves = 4
	fn.seed = randi()

	var tex3d := NoiseTexture3D.new()
	tex3d.noise = fn
	tex3d.seamless = true
	tex3d.width = 128
	tex3d.height = 128
	tex3d.depth = 128
	tex3d.generate()

	# Shader setup
	var shader := Shader.new()
	shader.code = preload("res://moving_terrain_shader.gdshader").code
	material.shader = shader
	material.set_shader_parameter("HEIGHTMAP", tex3d)
	material.set_shader_parameter("amplitude", amplitude)
	material.set_shader_parameter("scroll_speed", scroll_speed)
	material.set_shader_parameter("world_scale", world_scale)
	material.set_shader_parameter("tint", Color(0.24, 0.55, 0.33))
	material.set_shader_parameter("scroll_dir", Vector3(0, 0, 1)) # move towards -Z visually

	self.material_override = material