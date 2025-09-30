extends Control

var player_name: String = ""

@export var text_input: LineEdit
@export var name_select_box: Container
@export var leaderboard: Leaderboard
@export var leaderboard_box: Container
@export var name_container: Container
@export var score_container: Container
@export var round_container: Container
@export var label_theme: Theme


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
	var leaderboard_tween := create_tween()
	leaderboard_box.modulate.a = 0.0
	leaderboard_tween.tween_property(leaderboard_box, "modulate:a", 1.0, 0.5)
	leaderboard_box.show()
	print("Leaderboard data received: ", data)
	for row in data:
		for column in row:
			print("  Column: ", column)
			match column:
				"name":
					print("Adding name: ", row[column])
					var name_label := Label.new()
					name_label.text = str(row[column])
					name_label.theme = label_theme
					name_container.add_child(name_label)
				"score":
					print("Adding score: ", row[column])
					var score_label := Label.new()
					score_label.text = str(int(row[column]))
					score_label.theme = label_theme
					score_container.add_child(score_label)
				"round":
					print("Adding round: ", row[column])
					var round_label := Label.new()
					round_label.text = str(int(row[column]))
					round_label.theme = label_theme
					round_container.add_child(round_label)
				
		print("Row: ", row)
