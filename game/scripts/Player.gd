extends KinematicBody2D
class_name Player

const PLAYER_SPEED := 100.0        # Movement speed in pixels per second
const SPRINT_FACTOR := 3.5         # How much faster sprinting is than sneaking

enum state {
	WALKING,
	SPRINTING,
	IDLE
}

var player_state = state.IDLE

signal noise_made

func _process(delta):
	
	# Handle movement direction
	var move_vec : Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	
	# Handle movement speed
	move_vec = move_vec.normalized()
	if Input.is_action_pressed("sprint"):
		move_vec *= SPRINT_FACTOR
	move_and_collide(move_vec * PLAYER_SPEED * delta)
	
	# Update player state if appropriate
	if move_vec == Vector2(0, 0):
		player_state = state.IDLE
		$TemporarySprite.stop()
	elif Input.is_action_pressed("sprint"):
		player_state = state.SPRINTING
		if not $TemporarySprite.is_playing():
			$TemporarySprite.play()
	else:
		player_state = state.WALKING
		if not $TemporarySprite.is_playing():
			$TemporarySprite.play()
	
	# Trigger echo on sprite frames where foot hits ground
	if player_state != state.IDLE and ($TemporarySprite.frame == 3 or $TemporarySprite.frame == 7):
		var echo_size = 0.5 if Input.is_action_pressed("sprint") else 0.36
		emit_signal("noise_made", echo_size, position)
