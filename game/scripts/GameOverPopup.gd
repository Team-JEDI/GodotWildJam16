extends PopupDialog

func _on_ckpt_btn():
	LoadHelper.is_loading = true
	var num = LoadHelper.save_data["level_number"]
	get_tree().change_scene("res://scenes/levels/%d.tscn" % num)

func _on_quit_btn():
	get_tree().change_scene("res://scenes/MainMenu.tscn")
