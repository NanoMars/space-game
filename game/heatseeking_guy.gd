extends Enemy  # Ensure Enemy extends RigidBody2D in 2D

@onready var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
@export var speed: float = 300.0   # force magnitude or tweak to taste
@export var damage_dealt: float = 20.0

# Flocking parameters
@export_group("Flocking")
@export var flocking_force: float = 1
@export var separation_weight: float = 1.5  # Avoid crowding neighbors
@export var alignment_weight: float = 0.8   # Match velocity with neighbors
@export var cohesion_weight: float = 0.6    # Steer towards center of neighbors
@export var neighbor_distance: float = 150.0  # Detection radius for flockmates
@export var separation_distance: float = 50.0  # Minimum distance to maintain

func _ready() -> void:
	super._ready()
	contact_monitor = true
	max_contacts_reported = 8
	body_entered.connect(_on_body_entered)
	
	# Add to heatseeking_enemy group for flocking behavior
	add_to_group("heatseeking_enemy")

func _physics_process(delta: float) -> void:
	if player:
		var direction: Vector2 = (player.global_position - global_position).normalized()
		
		# Get flocking forces
		var flock_force: Vector2 = calculate_flocking_force()
		
		# Combine seeking and flocking behaviors
		var desired_force: Vector2 = (direction * speed + flock_force * flocking_force) * delta
		apply_force(desired_force)

	# Face the velocity direction in 2D
	var v: Vector2 = linear_velocity
	if v.length_squared() > 0.0001:
		rotation = v.angle()

func calculate_flocking_force() -> Vector2:
	var separation: Vector2 = Vector2.ZERO
	var alignment: Vector2 = Vector2.ZERO
	var cohesion: Vector2 = Vector2.ZERO
	var neighbor_count: int = 0
	
	# Find all other heatseeking enemies
	var enemies: Array[Node] = get_tree().get_nodes_in_group("heatseeking_enemy")
	
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
			
		var other: Node2D = enemy as Node2D
		if not other:
			continue
			
		var distance: float = global_position.distance_to(other.global_position)
		
		# Only consider neighbors within detection radius
		if distance < neighbor_distance and distance > 0.01:
			neighbor_count += 1
			
			# Separation: steer away from nearby neighbors
			if distance < separation_distance:
				var diff: Vector2 = (global_position - other.global_position).normalized()
				diff /= distance  # Weight by distance (closer = stronger)
				separation += diff
			
			# Alignment: match velocity with neighbors
			if other is RigidBody2D:
				var other_body: RigidBody2D = other as RigidBody2D
				alignment += other_body.linear_velocity
			
			# Cohesion: move towards average position of neighbors
			cohesion += other.global_position
	
	# Average and apply weights
	var flock_force: Vector2 = Vector2.ZERO
	
	if neighbor_count > 0:
		# Separation
		if separation.length_squared() > 0:
			separation = separation.normalized() * separation_weight * speed
			flock_force += separation
		
		# Alignment
		alignment /= neighbor_count
		if alignment.length_squared() > 0:
			alignment = alignment.normalized() * alignment_weight * speed
			flock_force += alignment
		
		# Cohesion
		cohesion /= neighbor_count
		cohesion = (cohesion - global_position).normalized() * cohesion_weight * speed
		flock_force += cohesion
	
	return flock_force

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("damage"):
			body.damage(damage_dealt, self)
		if health and health.has_method("die"):
			health.die(self)
