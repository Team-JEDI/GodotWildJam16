extends Control

onready var player = $VideoPlayer

func _ready():
	player.connect("finished", self, "_on_video_finished")
	player.play()

func _on_video_finished():
	get_tree().change_scene("res://scenes/levels/1.tscn")
