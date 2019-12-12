extends Node2D

onready var Echo = preload("res://scenes/Echo.tscn")

export var level_num : int = 0

func _ready():
	$Character.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("hour_elapsed", self, "_on_hour_elapsed")
	for ckpt in $checkpoints.get_children():
		ckpt.connect("game_saved", self, "_on_game_saved")
	
	if LoadHelper.is_loading:
		restore_save_data()
	else:
		# Setup new game
		pass

func _on_noise_made(echo_scale, location):
	var new_echo = Echo.instance()
	add_child(new_echo)
	new_echo.position = location
	new_echo.trigger_echo(echo_scale)

func _on_hour_elapsed(hours_left):
	# TODO: Create popup telling players number of hours to midnight
	pass

func _on_game_saved():
	
	# Save game info in a dictionary
	LoadHelper.save_data["level_number"] = level_num
	LoadHelper.save_data["player_loc"] = $Character.position
	LoadHelper.save_data["player_health"] = $Character.player_health
	LoadHelper.save_data["hours_left"] = GameTimer.hours_remaining
	LoadHelper.save_data["secs_left"] = GameTimer.global_timer.time_left
	var enemy_locs : Array = []
	for enemy in $enemies.get_children():
		enemy_locs.append(enemy.position)
	LoadHelper.save_data["enemy_locs"] = enemy_locs
	
	LoadHelper.write_save_data()

func restore_save_data():
	
	$Character.position = LoadHelper.save_data["player_loc"]
	$Character.player_health = LoadHelper.save_data["player_health"]
	GameTimer.hours_remaining = LoadHelper.save_data["hours_left"]
	GameTimer.global_timer.time_left = LoadHelper.save_data["secs_left"]
	
	var enemies = $enemies.get_children()
	for index in range(len(LoadHelper.save_data["enemy_locs"])-1):
		enemies[index].position = LoadHelper.save_data["enemy_locs"][index]
	
	GameTimer.global_timer.start()
