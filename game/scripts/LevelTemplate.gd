extends Node2D

onready var Echo = preload("res://scenes/Echo.tscn")

func _ready():
	$Character.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("noise_made", self, "_on_noise_made")
	GameTimer.connect("hour_elapsed", self, "_on_hour_elapsed")
	
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
