extends Control

@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var player_health: Health = player.get_node("Health")
@onready var health_bar: ProgressBar = $HealthBar

func _ready() -> void:
	player_health.health_changed.connect(_on_health_changed)
	health_bar.value = player_health.health / player_health.max_health * health_bar.max_value

func _on_health_changed(new_health: float) -> void:
	health_bar.value = new_health / player_health.max_health * health_bar.max_value
