extends Sprite3D
@export var transition_scene: PackedScene
@export var rect_with_material: ColorRect
func _ready() -> void:
	var tween = get_tree().create_tween()
	var sm := rect_with_material.material as ShaderMaterial
	
	if sm:
		tween.tween_method(
			func(v): sm.set_shader_parameter("playhead", v),
			0.0, PI * 2, 2.0
		)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	SceneManager.change_scene(transition_scene, {"transition": "fade"})
