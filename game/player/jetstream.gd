extends Node2D

@export var active: bool:
	set(value):
		
		if value and value != active:
			_on_timeout()
		active = value
	get:
		return active
var last_frame_active: bool = false
@export var speed: float = 200.0
@export var update_speed: float = 0.03

@export var trail_gradient: Gradient
@export var max_lifetime_sec: float = 2.0
@export var max_distance: float = 500.0

var lines: Array[Line2D] = []
var point_lifetimes: Array[Array] = []  # Array of arrays, each containing lifetimes for points in a line
var current_line: Line2D = null

var timer: Timer

var starfield: ColorRect
	
func _ready() -> void:
	timer = Timer.new()
	timer.autostart = true
	timer.wait_time = update_speed
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	starfield = get_tree().get_first_node_in_group("starfield")
	
	

	
func _on_timeout() -> void:
	if not active:
		return
	if not current_line:
		current_line = Line2D.new()
		current_line.width = 2
		current_line.top_level = true
		if trail_gradient:
			current_line.gradient = trail_gradient
		add_child(current_line)
		lines.append(current_line)
		point_lifetimes.append([])
	current_line.add_point(global_position)
	# Add lifetime for the new point
	var line_index = lines.find(current_line)
	if line_index != -1:
		point_lifetimes[line_index].append(0.0)
	

func _process(delta: float) -> void:
	if starfield:
		speed = (starfield.material.get_shader_parameter("speed") / starfield.material.get_shader_parameter("compression")) * 1500
	if active and not last_frame_active:
		current_line = null
	elif not active and last_frame_active:
		current_line = null
	if current_line and current_line.get_point_count() == 0:
		current_line.add_point(global_position)
		return
	var last_index: int

	if active:
		if current_line != null and current_line.get_point_count() > 1:
			last_index = current_line.get_point_count() - 1
			current_line.set_point_position(last_index, global_position)
			# Reset the lifetime of the dynamically locked point so it doesn't age
			var line_index = lines.find(current_line)
			if line_index != -1 and last_index < point_lifetimes[line_index].size():
				point_lifetimes[line_index][last_index] = 0.0
	else:
		if current_line != null and current_line.get_point_count() > 1:
			last_index = current_line.get_point_count() - 2
	for i in range(lines.size() - 1, -1, -1):
		var line = lines[i]
		_update_line(line, delta, i)
	last_frame_active = active

func _update_line(line: Line2D, delta: float, line_index: int) -> void:
	if line.get_point_count() < 2:
		return
	
	# Update the first point to always follow the player (dynamically locked point)
	line.set_point_position(0, global_position)
	# Reset lifetime of the dynamically locked point
	if point_lifetimes[line_index].size() > 0:
		point_lifetimes[line_index][0] = 0.0
	
	# Update lifetimes for all points except the first one
	for i in range(1, point_lifetimes[line_index].size()):
		point_lifetimes[line_index][i] += delta
	
	# Remove points that are too old or too far (from index 1 onwards, keeping the locked point)
	while point_lifetimes[line_index].size() > 1:
		var should_remove = false
		
		# Check if point is too old (check index 1 since 0 is locked)
		if point_lifetimes[line_index][1] >= max_lifetime_sec:
			should_remove = true
		
		# Check if point is too far from the current position
		if line.get_point_count() > 1:
			var distance_to_player = line.get_point_position(1).distance_to(global_position)
			if distance_to_player > max_distance:
				should_remove = true
		
		if should_remove:
			line.remove_point(1)
			point_lifetimes[line_index].remove_at(1)
		else:
			break
	
	# If line has no points left (except the locked one), remove it
	if line.get_point_count() < 2:
		line.queue_free()
		lines.remove_at(line_index)
		point_lifetimes.remove_at(line_index)
		if current_line == line:
			current_line = null
		return
	
	var point_count: int
	if line == current_line and active:
		point_count = line.get_point_count() - 1
	else:
		point_count = line.get_point_count()
	# Skip the first point (index 0) since it's dynamically locked to the player
	for i in range(1, point_count):
		var point: Vector2 = line.get_point_position(i)
		point.y += speed * delta

		line.set_point_position(i, point)
