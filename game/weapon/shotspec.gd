# shotspec.gd (2D version)
extends RefCounted
class_name ShotSpec

var dir: Vector2
var offset: Vector2

func _init(dir: Vector2 = Vector2.UP, offset: Vector2 = Vector2.ZERO) -> void:
	dir = dir.normalized()
	self.dir = dir
	self.offset = offset