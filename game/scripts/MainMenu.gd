extends Control

func _ready():
	
	# Only show "LOAD" btn if there's a game to load
	if not File.new().file_exists(LoadHelper.SAVE_FILEPATH):
		$VBoxContainer/LoadBtn.disabled = true

func _on_load_game():
	LoadHelper.is_loading = true
	var num = LoadHelper.save_data["level_number"]
	get_tree().change_scene("res://scenes/levels/%d.tscn" % num)

func _on_new_game():
	LoadHelper.is_loading = false
	get_tree().change_scene("res://scenes/levels/1.tscn")

func _on_view_credits():
	# TODO: Create credits page
	pass

func _on_quit_game():
	get_tree().quit()
