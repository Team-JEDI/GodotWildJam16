extends Node2D

const TIME_ALERT_LABEL_TEXT := "%d HOUR%s REMAINING"

onready var Echo = preload("res://scenes/Echo.tscn")
onready var alert = $ui/time_alert
onready var tut_label = $ui/tut_text
onready var go_popup = $ui/gameover_popup
onready var pause_popup = $ui/pause_popup

export var level_num : int = 0

var darkness_mat = preload("res://assets/textures/darkness_material.tres")

func _ready():
	$Character.connect("noise_made", self, "_on_noise_made")
	$Character.connect("game_over", self, "_on_game_over")
	GameTimer.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("hour_elapsed", self, "_on_hour_elapsed")
	GameTimer.connect("game_over", self, "_on_game_over")
	for ckpt in $checkpoints.get_children():
		ckpt.connect("game_saved", self, "_on_game_saved")
	$EndZone.connect("body_entered", self, "_on_level_finished")
	for enemy in $EnemyHandler/Enemies.get_children():
		enemy.connect("enemy_noise_made", self, "_on_noise_made")
	for interactable in $Interactables.get_children():
		if "Key" in interactable.name:
			interactable.connect("key_noise_made", self, "_on_noise_made")
	if has_node("VOTriggers"):
		for trigger in $VOTriggers.get_children():
			trigger.connect("instruction_triggered", self, "_on_instruction_text")
	
	if level_num == 1:
		GameTimer.start_new_game()
	
	if LoadHelper.is_loading:
		restore_save_data()
	else:
		_on_game_saved()
	
	_set_materials_for_lighting()
	MusicAndAmbience.set_play_ambience(true)

	if get_node("OldMan"):
		get_node("OldMan").player = $Character

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = true
		pause_popup.popup_centered()

func _on_noise_made(echo_scale, location):
	var new_echo = Echo.instance()
	add_child(new_echo)
	new_echo.position = location
	new_echo.trigger_echo(echo_scale)

func _on_hour_elapsed(hours_left):
	
	alert.text = TIME_ALERT_LABEL_TEXT % [hours_left, "s" if hours_left > 1 else ""]
	
	# Fade in
	var label_tween = Tween.new()
	add_child(label_tween)
	label_tween.interpolate_property(alert, "modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	label_tween.start()
	yield(label_tween, "tween_all_completed")
	
	# Wait a few seconds
	yield(get_tree().create_timer(3.0), "timeout")
	
	# Fade out
	label_tween.interpolate_property(alert, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	label_tween.start()
	yield(label_tween, "tween_all_completed")
	label_tween.queue_free()

func _on_instruction_text(instruction_num):
	
	match instruction_num:
		1:
			tut_label.text = "Use WASD to move\nPress 'Q' to ring the bell while holding it"
		2:
			tut_label.text = "Press 'TAB' to switch between your bell and keys\nPress 'E' to open gates"
		3:
			tut_label.text = "Use the bell to find keys"
		4:
			tut_label.text = "Press 'Q' to unlock gates while holding keys"
		
	# Fade in
	var label_tween = Tween.new()
	add_child(label_tween)
	label_tween.interpolate_property(tut_label, "modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	label_tween.start()
	yield(label_tween, "tween_all_completed")
	
	# Wait a few seconds
	yield(get_tree().create_timer(3.0), "timeout")
	
	# Fade out
	label_tween.interpolate_property(tut_label, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	label_tween.start()
	yield(label_tween, "tween_all_completed")
	label_tween.queue_free()

func _on_level_finished(body):
	if body is Player:
		match level_num:
			1:
				get_tree().change_scene("res://scenes/levels/2.tscn")
			2:
				get_tree().change_scene("res://scenes/EndCutScene.tscn")

func _on_game_over():
	go_popup.popup_centered()
	get_tree().paused = true

func _on_game_saved():
	
	# Save game info in a dictionary
	LoadHelper.save_data["level_number"] = level_num
	LoadHelper.save_data["player_loc"] = $Character.position
	LoadHelper.save_data["player_health"] = $Character.player_health
	LoadHelper.save_data["hours_left"] = GameTimer.hours_remaining
	LoadHelper.save_data["secs_left"] = GameTimer.global_timer.time_left
	
	var enemy_locs : Array = []
	for enemy in $EnemyHandler/Enemies.get_children():
		enemy_locs.append(enemy.position)
	LoadHelper.save_data["enemy_locs"] = enemy_locs
	
	LoadHelper.write_save_data()

func restore_save_data():
	
	$Character.position = LoadHelper.save_data["player_loc"]
	$Character.player_health = LoadHelper.save_data["player_health"]
	GameTimer.hours_remaining = LoadHelper.save_data["hours_left"]
	GameTimer.global_timer.wait_time = LoadHelper.save_data["secs_left"]
	
	var enemies = $EnemyHandler/Enemies.get_children()
	for index in range(len(LoadHelper.save_data["enemy_locs"])-1):
		enemies[index].position = LoadHelper.save_data["enemy_locs"][index]
	
	GameTimer.global_timer.start()

func _set_materials_for_lighting():
	for child in $Tilemaps.get_children():
		child.set_material(darkness_mat)
	for child in $Interactables.get_children():
		for subchild in child.get_children():
			if subchild is Sprite:
				subchild.set_material(darkness_mat)	
	for child in $EnemyHandler/Enemies.get_children():
		for subchild in child.get_children():
			if subchild is Sprite:
				subchild.set_material(darkness_mat)	
