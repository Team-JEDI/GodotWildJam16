extends KinematicBody2D
class_name Player

const PLAYER_SPEED := 100.0        # Movement speed in pixels per second
const SPRINT_FACTOR := 3.5         # How much faster sprinting is than sneaking
const TILE_SIZE := 96.0
const BELL_COOLDOWN_TIME := 1.0
const DRAIN_HEALTH_COOLDOWN_TIME := 1.0

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
var player_health : int = 5
var step_frames : Array = [1, 5, 10, 14, 19, 23]
var holding_item : String = "bell"
var key_count : int = 0
var has_level_end_key : bool = false
var last_step_frame : int = 0
var mash_bell_ct : int = 0
var you_mashed_well_son : bool = false
var bell_cooldown := Timer.new()
var can_ring_bell : bool = true
var drain_health_timer := Timer.new()
var can_drain_health : bool = false
var prev_player_state = player_state

signal noise_made
signal game_over

func _ready():
	Events.connect("item_destroy", self, "_on_item_destroy")
	Events.connect("item_pickup", self, "_on_item_pickup")
	add_child(bell_cooldown)
	bell_cooldown.set_one_shot(true)
	bell_cooldown.connect("timeout", self, "_on_bell_cooldown_timeout")
	add_child(drain_health_timer)
	drain_health_timer.set_one_shot(true)
	drain_health_timer.connect("timeout", self, "_on_drain_health_timer_timeout")
	$Keys.hide()

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

		# Handle switching items	
		if Input.is_action_just_pressed("switch_item"):	
			if holding_item == "bell":
				$Bell.hide()
				$Keys.show()
				holding_item = "keys"
				print("player is holding [keys]")
			else:
				$Bell.show()
				$Keys.hide()
				holding_item = "bell"	
				print("player is holding [bell]")

		# Handle using items	
		if Input.is_action_just_pressed("use_item"):	
			if holding_item == "bell" and can_ring_bell:
				$BellSound.play()
				can_ring_bell = false
				bell_cooldown.start(BELL_COOLDOWN_TIME)
				emit_signal("noise_made", 0.8, position)
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
			if $Sprite.frame != last_step_frame:
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
				last_step_frame = $Sprite.frame	
	else:
		holding_item = "bell"
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Feast_Idle")
		if prev_player_state != player_state:
			# TODO: change player sprite
			$AnimationPlayer.play("Feast_Idle")
			drain_health_timer.start(DRAIN_HEALTH_COOLDOWN_TIME)
			$Sprite.hide()
			$Keys.hide()
			$Bell.hide()
			$Feast.show()
		elif can_drain_health:
			can_drain_health = false
			player_health -= 1
			print("player health decreased to %d"%player_health)
			drain_health_timer.start(DRAIN_HEALTH_COOLDOWN_TIME)
		if Input.is_action_just_pressed("use_item") and can_ring_bell:	
			$AnimationPlayer.play("Feast_Bell")
			$BellSound.play()
			can_ring_bell = false
			bell_cooldown.start(BELL_COOLDOWN_TIME)
			emit_signal("noise_made", 1.2, position)
			mash_bell_ct += 1
		if mash_bell_ct >= 3:
			player_state = state.IDLE
			$Sprite.show()
			$Keys.show()
			$Bell.show()
			$Feast.hide()
			can_drain_health = false
			you_mashed_well_son = true
			player_state = state.IDLE
			mash_bell_ct = 0
	prev_player_state = player_state		
	z_index = round(position.y / TILE_SIZE)	
	if player_health <= 0:
		emit_signal("game_over")

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

func _on_bell_cooldown_timeout():
	can_ring_bell = true

func _on_drain_health_timer_timeout():
	can_drain_health = true
