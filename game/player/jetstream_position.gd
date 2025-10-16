extends Node2D

@export var object: Node3D
@export var left_jetstream: Node2D
@export var right_jetstream: Node2D
@export var distance: float = 13

func _process(delta: float) -> void:
    if not is_instance_valid(object):
        return
    var angle = object.rotation.z
    var offset: float = cos(angle) * distance
    if is_instance_valid(left_jetstream):
        left_jetstream.position.x = -offset
    if is_instance_valid(right_jetstream):
        right_jetstream.position.x = offset