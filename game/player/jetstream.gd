extends Node2D

@export var active: bool = true
var last_frame_active: bool = false
@export var speed: float = 200.0

var lines: Array[Line2D] = []
var current_line: Line2D = null

var timer: Timer
	
func _ready() -> void:
	self.top_level = true
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.1
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	
	

	
func _on_timeout() -> void:
	if not active:
		return
	if not current_line:
		current_line = Line2D.new()
		current_line.width = 2
		add_child(current_line)
		lines.append(current_line)
	current_line.add_point(to_local(get_parent().global_position))
	

func _process(delta: float) -> void:
	if active and not last_frame_active:
		current_line = null
	if current_line and current_line.get_point_count() == 0:
		current_line.add_point(to_local(get_parent().global_position))
		return
	var last_index: int
	
	if active:
		if current_line != null and current_line.get_point_count() > 1:
			last_index = current_line.get_point_count() - 1
			current_line.set_point_position(last_index, to_local(get_parent().global_position))
	else:
		if current_line != null and current_line.get_point_count() > 1:
			last_index = current_line.get_point_count() - 2
	for line in lines:
		_update_line(line, delta)
	# for i in range(last_index):
	# 	var point: Vector2 = get_point_position(i)
	# 	point.y += speed * delta
	# 	set_point_position(i, point)
	# if get_point_count() < 2:
	# 	return
	# var last_point: Vector2 = get_point_position(1)
	# if last_point.y > get_viewport().get_visible_rect().size.y + 100:
	# 	remove_point(0)

func _update_line(line: Line2D, delta: float) -> void:
	if line.get_point_count() < 2:
		return
	for i in range(line.get_point_count()):
		var point: Vector2 = line.get_point_position(i)
		point.y += speed * delta
		line.set_point_position(i, point)
	if line.get_point_position(1).y > get_viewport().get_visible_rect().size.y + 100:
		line.remove_point(0)
	if line.get_point_count() < 2:
		line.queue_free()
		lines.erase(line)
		if current_line == line:
			current_line = null
	last_frame_active = active
