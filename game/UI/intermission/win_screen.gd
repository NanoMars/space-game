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
@export_file("*.tscn") var main_menu_scene: String
@export_file("*.tscn") var game_scene: String

var has_leaderboard_data: bool = false
var leaderboard_data = null
var leaderboard_tweened: bool = false


func _ready() -> void:
	leaderboard.leaderboard_request_completed.connect(_on_leaderboard_request_completed)
	name_select_box.show()
	leaderboard_box.hide()
	leaderboard.fetch_top(25)
	if Settings.get("demo mode") == false:
			Settings.set("tutorial enabled", false)
	get_tree().get_root().get_node("Cursor").get_node("FilterOverlay").visible = false


func _on_name_submit_button_pressed() -> void:
	if text_input.text.strip_edges() == "" or text_input.text == "":
		return

	player_name = text_input.text
	var name_tween := create_tween()
	name_tween.tween_property(name_select_box, "modulate:a", 0.0, 0.5)
	await name_tween.finished
	name_select_box.hide()
	leaderboard.submit_score(player_name, ScoreManager.score, ScoreManager.currentRound)
	leaderboard.fetch_top(25)
	display_leaderboard(leaderboard_data)

func _on_leaderboard_request_completed(data):

	leaderboard_data = data
	has_leaderboard_data = true
	display_leaderboard(data)
	
func display_leaderboard(data) -> void:
	if not has_leaderboard_data or name_select_box.visible:
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
			print("  Column: ", column)
			match column:
				"name":
					print("Adding name: ", row[column])
					var name_label := Label.new()
					name_label.text = str(row[column])
					name_label.theme = label_theme
					name_label.add_to_group("leaderboard_item")
					name_container.add_child(name_label)
				"score":
					print("Adding score: ", row[column])
					var score_label := Label.new()
					score_label.text = str(int(row[column]))
					score_label.theme = label_theme
					score_label.add_to_group("leaderboard_item")
					score_container.add_child(score_label)
				"round":
					print("Adding round: ", row[column])
					var round_label := Label.new()
					round_label.text = str(int(row[column]))
					round_label.theme = label_theme
					round_label.add_to_group("leaderboard_item")
					round_container.add_child(round_label)
	if not leaderboard_tweened:
		var leaderboard_tween := create_tween()
		leaderboard_box.modulate.a = 0.0
		leaderboard_tween.tween_property(leaderboard_box, "modulate:a", 1.0, 0.5)
		leaderboard_box.show()
		await leaderboard_tween.finished
		leaderboard_tweened = true
	print("Leaderboard data received: ", data)
	
				


func _on_return_button_pressed() -> void:
	ScoreManager.reset()
	SceneManager.change_scene(main_menu_scene)
	get_tree().get_root().get_node("Cursor").get_node("FilterOverlay").visible = true


func _on_play_button_pressed() -> void:
	ScoreManager.reset()
	SceneManager.change_scene(game_scene)
	get_tree().get_root().get_node("Cursor").get_node("FilterOverlay").visible = true
