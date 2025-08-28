extends Control

@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var player_health: Health = player.get_node("Health")
@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel

func _ready() -> void:
	player_health.health_changed.connect(_on_health_changed)
	health_bar.value = player_health.health / player_health.max_health * health_bar.max_value

	ScoreManager.score_changed.connect(_on_score_changed)
	score_label.text = str(ScoreManager.score)

func _on_health_changed(new_health: float) -> void:
	health_bar.value = new_health / player_health.max_health * health_bar.max_value

func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)
