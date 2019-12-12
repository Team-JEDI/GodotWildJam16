extends Node

const SAVE_FILEPATH = "user://save.json"

var save_file : File = File.new()
var save_data : Dictionary = {}
var is_loading : bool = false

func _ready():
	load_save_data()

func load_save_data():
	
	# Try to load from file
	if save_file.file_exists(SAVE_FILEPATH):
		save_file.open(SAVE_FILEPATH, File.READ)
		save_data = JSON.parse(save_file.get_var()).result
		save_file.close()
		
	else:
		# No save exists!
		print("No save file :(")

func write_save_data():
	save_file.open(SAVE_FILEPATH, File.WRITE)
	save_file.store_string(JSON.print(save_data))
	save_file.close()
