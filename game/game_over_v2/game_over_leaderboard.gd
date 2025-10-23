extends Control

var player_name: String = "TestPlayer"

@export var leaderboard: Leaderboard
@export var leaderboard_box: Container
@export var name_container: Container
@export var score_container: Container
@export var round_container: Container
@export var label_theme: Theme
@export_file("*.tscn") var main_menu_scene: String
@export_file("*.tscn") var game_scene: String

var has_leaderboard_data: bool = false
var leaderboard_data = null


func _ready() -> void:
	leaderboard.leaderboard_request_completed.connect(_on_leaderboard_request_completed)
	leaderboard_box.show()
	await get_tree().process_frame
	leaderboard.submit_score(player_name, ScoreManager.score, ScoreManager.currentRound)
	leaderboard.fetch_top(25)
	if Settings.get("demo mode") == false:
			Settings.set("tutorial enabled", false)
	get_tree().get_root().get_node("Cursor").get_node("FilterOverlay").visible = false



func _on_leaderboard_request_completed(data):

	leaderboard_data = data
	has_leaderboard_data = true
	display_leaderboard(data)

func fetch_and_display_leaderboard() -> void:
	leaderboard.fetch_top(25)

func display_leaderboard(data = []) -> void:
	if not has_leaderboard_data:
		return
	
	for child in name_container.get_children():
		if child.is_in_group("leaderboard_item"):
			child.queue_free()
	for child in score_container.get_children():
		if child.is_in_group("leaderboard_item"):
			child.queue_free()
	for child in round_container.get_children():
		if child.is_in_group("leaderboard_item"):
			child.queue_free()
	for row in data:
		for column in row:
			match column:
				"name":
					var name_label := Label.new()
					name_label.text = str(row[column])
					name_label.theme = label_theme
					name_label.add_to_group("leaderboard_item")
					name_container.add_child(name_label)
				"score":
					var score_label := Label.new()
					score_label.text = str(int(row[column]))
					score_label.theme = label_theme
					score_label.add_to_group("leaderboard_item")
					score_container.add_child(score_label)
				"round":
					var round_label := Label.new()
					round_label.text = str(int(row[column]))
					round_label.theme = label_theme
					round_label.add_to_group("leaderboard_item")
					round_container.add_child(round_label)
	leaderboard_box.show()
