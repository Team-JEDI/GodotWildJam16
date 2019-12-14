extends Area2D
class_name VOTriggerArea

export var vo_line_num : int = 0

onready var vo_lines = [
	preload("res://assets/sounds/vo_line_01.wav"),
#	preload("res://assets/sounds/vo_line_02.wav"),
#	preload("res://assets/sounds/vo_line_03.wav"),
#	preload("res://assets/sounds/vo_line_04.wav"),
#	preload("res://assets/sounds/vo_line_05.wav"),
#	preload("res://assets/sounds/vo_line_06.wav"),
#	preload("res://assets/sounds/vo_line_07.wav"),
#	preload("res://assets/sounds/vo_line_08.wav"),
#	preload("res://assets/sounds/vo_line_09.wav"),
#	preload("res://assets/sounds/vo_line_10.wav"),
#	preload("res://assets/sounds/vo_line_11.wav"),
#	preload("res://assets/sounds/vo_line_12.wav"),
#	preload("res://assets/sounds/vo_line_13.wav")
]
onready var audio_player := $AudioStreamPlayer

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	
	if body is Player:
		match vo_line_num:
			1:
				play_line(0)
				play_line(1)
				queue_free()
			2:
				play_line(3)
				yield(get_tree().create_timer(0.3), "timeout")
				play_line(4)
				yield(get_tree().create_timer(0.4), "timeout")
				play_line(5)
				queue_free()
			3:
				play_line(6)
				play_line(7)
				queue_free()
			4:
				play_line(8)
				play_line(9)
				queue_free()
			5:
				if body.has_level_end_key:
					play_line(10)
					queue_free()
			6:
				play_line(11)
				# TODO: Player steps back
				play_line(12)
				queue_free()

func play_line(line_num : int):
	audio_player.stream = vo_lines[line_num]
	audio_player.play()
	yield(audio_player, "finished")
