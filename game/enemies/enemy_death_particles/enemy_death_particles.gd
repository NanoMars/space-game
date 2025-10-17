extends GPUParticles2D



func _on_finished() -> void:
    queue_free()    
func _ready() -> void:
    emitting = true