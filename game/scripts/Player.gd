extends KinematicBody2D
class_name Player

const PLAYER_SPEED := 100.0        # Movement speed in pixels per second
const SPRINT_FACTOR := 3.5         # How much faster sprinting is than sneaking
const TILE_SIZE := 96.0

enum state {
	WALKING,
	SPRINTING,
	IDLE,
	STUN
}

onready var walk_sounds = [
	preload("res://assets/sounds/player_walk_1.wav"), 
	preload("res://assets/sounds/player_walk_2.wav"),
	preload("res://assets/sounds/player_walk_3.wav"),
	preload("res://assets/sounds/player_walk_4.wav"),
	preload("res://assets/sounds/player_walk_5.wav"),
	preload("res://assets/sounds/player_walk_6.wav")
]
onready var run_sounds = [
	preload("res://assets/sounds/player_run_1.wav"),
	preload("res://assets/sounds/player_run_2.wav"),
	preload("res://assets/sounds/player_run_3.wav"),
	preload("res://assets/sounds/player_run_4.wav"),
	preload("res://assets/sounds/player_run_5.wav"),
	preload("res://assets/sounds/player_run_6.wav")
]

onready var step_sound_player = $FootSteps

var player_state = state.IDLE
var player_facing = "Down"
var last_facing = player_facing
var player_health : int = 4
var step_frames : Array = [1, 5, 10, 14, 19, 23]
var holding_item : String = "bell"
var key_count : int = 0
var has_level_end_key : bool = false

signal noise_made
signal game_over

func _ready():
	Events.connect("item_destroy", self, "_on_item_destroy")
	Events.connect("item_pickup", self, "_on_item_pickup")

func _physics_process(delta):
	
	# DEBUG COMMANDS -- REMOVE THESE BEFORE SHIPPING!!!
	if Input.is_action_just_pressed("ui_page_down"):
		emit_signal("game_over")
	
	# Handle movement direction
	var move_vec : Vector2 = Vector2(0, 0)
	if player_state != state.STUN:
		if Input.is_action_pressed("move_up"):
			player_facing = "Up"
			move_vec.y -= 1
		if Input.is_action_pressed("move_down"):
			player_facing = "Down"
			move_vec.y += 1
		if Input.is_action_pressed("move_left"):
			player_facing = "Left"
			move_vec.x -= 1
		if Input.is_action_pressed("move_right"):
			player_facing = "Right"
			move_vec.x += 1

		# Handle using items	
		if Input.is_action_just_pressed("switch_item"):	
			if holding_item == "bell":
				holding_item = "keys"
				print("player is holding [keys]")
			else:
				holding_item = "bell"	
				print("player is holding [bell]")
		if Input.is_action_just_pressed("use_item"):	
			if holding_item == "bell":
				emit_signal("noise_made", 1.2, position)
				Events.emit_signal("use_item", holding_item, key_count, has_level_end_key)	
			elif holding_item == "keys":
				Events.emit_signal("use_item", holding_item, key_count, has_level_end_key)	
	
		# Handle movement speed
		move_vec = move_vec.normalized()
		if Input.is_action_pressed("sprint"):
			move_vec *= SPRINT_FACTOR
		move_and_slide(move_vec * PLAYER_SPEED)
	
		# Update player state and animation if appropriate
		if move_vec == Vector2(0, 0):
			if player_state != state.IDLE or last_facing != player_facing:
				$AnimationPlayer.play("Idle%s"%player_facing)
			player_state = state.IDLE
		elif Input.is_action_pressed("sprint"):
			if player_state != state.SPRINTING or last_facing != player_facing:
				$AnimationPlayer.play("Walk%s"%player_facing)
				$AnimationPlayer.set_speed_scale(2.5)
			player_state = state.SPRINTING
		else:
			if player_state != state.WALKING or last_facing != player_facing: 
				$AnimationPlayer.play("Walk%s"%player_facing)
				$AnimationPlayer.set_speed_scale(1.0)
			player_state = state.WALKING
		last_facing = player_facing

		# Trigger echo and noise on sprite frames where foot hits ground
		if player_state != state.IDLE and $Sprite.frame in step_frames:
			var is_running = Input.is_action_pressed("sprint")
			var rand_sounds_index = randi() % 6
			if is_running:
				emit_signal("noise_made", 0.5, position)
				step_sound_player.stream = run_sounds[rand_sounds_index]
				step_sound_player.play()
			else:
				emit_signal("noise_made", 0.36, position)
				step_sound_player.stream = walk_sounds[rand_sounds_index]
				step_sound_player.play()
	else:
		# probably going to hide both creature and player sprites and show creature holding player sprite 
		# player devouring sounds
		# handle bell mash to get away from creature
		pass
	
	z_index = round(position.y / TILE_SIZE)	

func _on_item_destroy(item):
	if item == "key":
		key_count -= 1
	if item == "level end key":
		has_level_end_key = false	

func _on_item_pickup(item):
	if item == "key":
		print("key get")
		key_count += 1
	elif item == "level end key":
		print("level end key get")
		has_level_end_key = true	
