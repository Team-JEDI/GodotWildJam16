extends Control

onready var button_load = $Menu/VBoxContainer/LoadBtn
onready var menu = $Menu
onready var credits = $Credits

onready var music = $AudioStreamPlayer_Music
onready var ambience = $AudioStreamPlayer_Ambience
onready var video_player = $VideoPlayer
onready var blackout = $Blackout
onready var tween = $Tween

func _ready():
	video_player.play()
	# Only show "LOAD" btn if there's a game to load
	if not File.new().file_exists(LoadHelper.SAVE_FILEPATH):
		button_load.disabled = true
	# Set up music/ambience/fade-in
	ambience.volume_db = -40
	tween.interpolate_property(ambience, "volume_db", -40, -15, 5.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.interpolate_property(blackout, "color", Color.black, Color(0.0, 0.0, 0.0, 0.0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	tween.start()
	ambience.play()
	yield(get_tree().create_timer(1), "timeout")
	music.play()
	yield(get_tree().create_timer(1), "timeout")
	blackout.hide()

func _on_load_game():
	LoadHelper.is_loading = true
	var num = LoadHelper.save_data["level_number"]
	get_tree().change_scene("res://scenes/levels/%d.tscn" % num)

func _on_new_game():
	LoadHelper.is_loading = false
	get_tree().change_scene("res://scenes/levels/1.tscn")

func _on_view_credits():
	menu.hide()
	credits.show()

func _on_BackBtn_pressed():
	menu.show()
	credits.hide()

func _on_quit_game():
	get_tree().quit()

func _on_VideoPlayer_finished():
	video_player.play()
