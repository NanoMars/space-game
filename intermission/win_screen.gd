extends Control

var player_name: String = ""

@export var text_input: LineEdit
@export var name_select_box: Container
@export var leaderboard: Leaderboard


func _ready() -> void:
	leaderboard.leaderboard_request_completed.connect(_on_leaderboard_request_completed)
	name_select_box.show()


func _on_name_submit_button_pressed() -> void:
	if text_input.text.strip_edges() == "" or text_input.text == "":
		return

	print("Name submitted: ", text_input.text)
	player_name = text_input.text
	var name_tween := create_tween()
	name_tween.tween_property(name_select_box, "modulate:a", 0.0, 0.5)
	await name_tween.finished
	name_select_box.hide()
	leaderboard.submit_score(player_name, ScoreManager.score, ScoreManager.currentRound)
	leaderboard.fetch_top(25)

func _on_leaderboard_request_completed(data):
	print("Leaderboard data received: ", data)
