extends Area2D

export var vo_line_num : int = 0
var already_triggered : bool = false

onready var audio_player := $AudioStreamPlayer

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	
	if body is Player and not already_triggered:
		
		print("Player entered VO area %d" % vo_line_num)
		already_triggered = true
		
		match vo_line_num:
			1:
				play_line(1)
				yield(audio_player, "finished")
				queue_free()
			2:
				play_line(2)
				yield(audio_player, "finished")
				yield(get_tree().create_timer(1.0), "timeout")
				play_line(3)
				yield(audio_player, "finished")
				yield(get_tree().create_timer(2.5), "timeout")
				play_line(4)
				yield(audio_player, "finished")
				queue_free()
			3:
				play_line(5)
				yield(audio_player, "finished")
				queue_free()
			4:
				play_line(6)
				yield(audio_player, "finished")
				queue_free()
			5:
				if body.has_level_end_key:
					play_line(7)
					yield(audio_player, "finished")
					queue_free()
			6:
				play_line(8)
				yield(audio_player, "finished")
				# TODO: Player steps back
				play_line(9)
				yield(audio_player, "finished")
				queue_free()

func play_line(line_num : int):
	var line_file = "res://assets/sounds/vo_line_%02d.ogg" % line_num
	var line = load(line_file)
	audio_player.stream = line
	audio_player.play()
