extends PopupDialog

func _on_resume():
	get_tree().paused = false
	hide()

func _on_load():
	get_tree().paused = false
	LoadHelper.is_loading = true
	var num = LoadHelper.save_data["level_number"]
	get_tree().change_scene("res://scenes/levels/%d.tscn" % num)

func _on_quit_btn():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")
