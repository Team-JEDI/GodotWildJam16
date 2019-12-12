extends Node

const SAVE_FILEPATH = "usr://save.json"

var save_file : File = File.new()
var save_data : Dictionary = {}
var is_loading : bool = false
