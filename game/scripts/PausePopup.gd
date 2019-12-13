extends PopupDialog

func _on_resume():
	get_tree().paused = false
	hide()

func _on_load():
	LoadHelper.is_loading = true
	# TODO: Implement level loading code
	get_tree().change_scene("res://scenes/LevelTemplate.tscn")

func _on_quit_btn():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
