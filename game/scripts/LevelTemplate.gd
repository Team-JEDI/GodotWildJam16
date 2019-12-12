extends Node2D

const SAVE_FILEPATH := "usr://save.json"

onready var Echo = preload("res://scenes/Echo.tscn")

func _ready():
	$Character.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("hour_elapsed", self, "_on_hour_elapsed")
	for ckpt in $checkpoints.get_children():
		ckpt.connect("game_saved", self, "_on_game_saved")
	
	yield(get_tree().create_timer(2.0), "timeout")
	GameTimer.start_new_game()

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
	var save_data : Dictionary = {}
	save_data["player_loc"] = $Character.position
	save_data["hours_left"] = GameTimer.hours_remaining
	save_data["secs_left"] = GameTimer.global_timer.time_left
	var enemy_locs : Array = []
	for enemy in $enemies.get_children():
		enemy_locs.append(enemy.position)
	save_data["enemy_locs"] = enemy_locs
	
	# Write dictionary to file
	var save_file : File = File.new()
	var err = save_file.open(SAVE_FILEPATH, File.WRITE)
	if err != OK:
		print("Could not save file!")
	else:
		save_file.store_string(JSON.print(save_data))
