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

var player_state = state.IDLE
var player_facing = "Down"
var last_facing = player_facing
var player_health : int = 4
var step_frames : Array = [1, 5, 10, 14, 19, 23]

signal noise_made
signal game_over

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

		# Trigger echo on sprite frames where foot hits ground
		if player_state != state.IDLE and $Sprite.frame in step_frames:
			var echo_size = 0.5 if Input.is_action_pressed("sprint") else 0.36
			emit_signal("noise_made", echo_size, position)
	else:			
		pass
	z_index = round(position.y / TILE_SIZE)	
	
