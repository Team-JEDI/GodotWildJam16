extends Node2D

onready var Echo = preload("res://scenes/Echo.tscn")

func _ready():
	$Character.connect("noise_made", self, "_on_noise_made")

func _on_noise_made(echo_scale, location):
	var new_echo = Echo.instance()
	add_child(new_echo)
	new_echo.position = location
	new_echo.trigger_echo(echo_scale)
