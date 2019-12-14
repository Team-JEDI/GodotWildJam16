extends Node

const FADE_DB_PER_STEP : float = 0.7
const FADE_DB_MAX : float = -6.0
const FADE_DB_MIN : float = -96.0

var ambience_stream = load("res://assets/sounds/Ambience.ogg")
var music_streams : Array = [
	load("res://assets/sounds/Amor_Fati.ogg"),
	load("res://assets/sounds/Fracti_Silentium.ogg"),
	load("res://assets/sounds/Timor_Mortis.ogg")
]
# need to take this extra step so project compiles correctly
var song_name_to_song_stream : Dictionary = {
	"somber": music_streams[0],
	"chase": music_streams[1],
	"post chase": music_streams[2]
}
var _players : Array = [
	AudioStreamPlayer.new(),
	AudioStreamPlayer.new(),
	AudioStreamPlayer.new()
]
var bus_name_to_bus_index : Dictionary = {
	"Ambience": 1,
	"Music0": 2,
	"Music1": 3 
}
var song_queue : Array = []
var current_music_player_i : int = 0
var fading : Array = ["", "", ""]

var song_names : Array = [
	"somber", "chase", "post chase"
]

func _ready():
	_players[0].bus = "Music0"
	_players[1].bus = "Music1"
	_players[2].bus = "Ambience"
	_players[2].set_stream(ambience_stream)
	add_child(_players[0])
	add_child(_players[1])
	add_child(_players[2])
	set_play_ambience(true)
	
func _process(delta):
	var end_fade : bool
	for i in range(3):
		end_fade = true
		if fading[i] == "in":
			end_fade = _fade_in(_players[i], false)
		elif fading[i] == "out":
			end_fade = _fade_out(_players[i], false)
		if end_fade:
			if fading[i] == "out":
				_players[i].stop()
			fading[i] = ""
	if song_queue.size() > 0:
		var other_player_i : int
		if current_music_player_i == 0:
			other_player_i = 1
		else:
			other_player_i = 0	
		if not _players[other_player_i].is_playing():
			fading[current_music_player_i] = "out"
			fading[other_player_i] = "in"
			_fade_out(_players[current_music_player_i], true)
			_fade_in(_players[other_player_i], true)
			_players[other_player_i].set_stream(song_name_to_song_stream[song_queue[0]])
			song_queue.pop_front()
			current_music_player_i = other_player_i
			_players[current_music_player_i].play()
	
func _fade_out(player, init) -> bool:
	var bus_index = bus_name_to_bus_index[player.bus]
	if init == true:
		AudioServer.set_bus_volume_db(bus_index, FADE_DB_MAX)
		return false
	else:	
		var bus_volume = AudioServer.get_bus_volume_db(bus_index)
		if bus_volume > FADE_DB_MIN:
			AudioServer.set_bus_volume_db(bus_index, bus_volume - FADE_DB_PER_STEP)
			return false
		else:
			return true	

func _fade_in(player, init) -> bool:
	var bus_index = bus_name_to_bus_index[player.bus]
	if init == true:
		AudioServer.set_bus_volume_db(bus_index, FADE_DB_MIN)
		return false
	else:	
		var bus_volume = AudioServer.get_bus_volume_db(bus_index)
		if bus_volume < FADE_DB_MAX:
			AudioServer.set_bus_volume_db(bus_index, bus_volume + FADE_DB_PER_STEP)
			return false
		else:
			return true	

func play_song(song_name):
	# "chase"      : fracti silentium
	# "post chase" : timor mortis
	# "somber"     : amor fati
	if song_name in song_names:
		song_queue.append(song_name)

func stop_music():
	song_queue.clear()
	fading[0] = "out"
	fading[1] = "out"

func set_play_ambience(setting : bool):
	if setting: 
		fading[2] = "in"
		_fade_in(_players[2], true)
		_players[2].play()
	else:	
		fading[2] = "out"
		_fade_out(_players[2], true)
