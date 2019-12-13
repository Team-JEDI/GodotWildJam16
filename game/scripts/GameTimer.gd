extends Node

# This script controls the time-remaining mechanic for the game

const HOURS_IN_GAME : int = 5        # Number of hours left at beginning
const SECS_IN_HOUR : int = 360       # 6 minutes IRL == 1 hour in-game
const BELL_ECHO_SIZE : int = 10000
const BELL_ECHO_POS := Vector2(0, -1000)

# TODO: Replace with actual bell sound
onready var belltower_sound : AudioStreamSample = preload("res://assets/sounds/temp_interactable_snd.wav")

var bell_player : AudioStreamPlayer = AudioStreamPlayer.new()
var global_timer : Timer = Timer.new()
var hours_remaining : int = 0

signal noise_made
signal hour_elapsed

func _ready():
	
	get_tree().get_root().call_deferred("add_child", global_timer)
	get_tree().get_root().call_deferred("add_child", bell_player)
	
	bell_player.volume_db = -10
	bell_player.set_stream(belltower_sound)
	
	global_timer.connect("timeout", self, "_on_hour_end")

func _on_hour_end():
	
	print("Hours left: %d" % hours_remaining)
	
	emit_signal("noise_made", BELL_ECHO_SIZE, BELL_ECHO_POS)
	emit_signal("hour_elapsed", hours_remaining)
	bell_player.play()
	
	if hours_remaining == 0:
		# TODO: Game over screen
		global_timer.stop()
	else:
		hours_remaining -= 1

func start_new_game():
	
	# Setup timer to elapse once every in-game hour
	global_timer.wait_time = SECS_IN_HOUR
	hours_remaining = HOURS_IN_GAME
	
	global_timer.start()

func load_timer(hours_left : int, secs_left : float):
	
	global_timer.stop()
	
	hours_remaining = hours_left
	global_timer.wait_time = secs_left
