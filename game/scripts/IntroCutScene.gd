extends Control

onready var player = $VideoPlayer

func _ready():
	player.connect("finished", self, "_on_video_finished")
	player.play()

func _process(delta):
	if Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER) or Input.is_mouse_button_pressed(BUTTON_LEFT):	
		get_tree().change_scene("res://scenes/levels/1.tscn")

func _on_video_finished():
	get_tree().change_scene("res://scenes/levels/1.tscn")
