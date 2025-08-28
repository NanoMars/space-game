extends RefCounted
class_name ShotSpec

var dir: Vector3
var offset: Vector3

func _init(dir: Vector3 = Vector3.FORWARD, offset: Vector3 = Vector3.ZERO) -> void:
	dir = dir.normalized()
	self.dir = dir
	self.offset = offset