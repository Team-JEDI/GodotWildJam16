extends PopupDialog

func _on_ckpt_btn():
	LoadHelper.is_loading = true
	# TODO: Implement level loading code
	get_tree().change_scene("res://scenes/LevelTemplate.tscn")

func _on_quit_btn():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
