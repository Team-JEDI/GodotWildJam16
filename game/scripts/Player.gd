extends KinematicBody2D
class_name Player

const PLAYER_SPEED := 100.0        # Movement speed in pixels per second
const SPRINT_FACTOR := 3.5         # How much faster sprinting is than sneaking

onready var player_light := $Light2D

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
	
	# Adjust visible area around player; large if moving, shrinking if still
	# Eventually this can be tied to sprite frames where footsteps are occurring
	if move_vec != Vector2(0,0):
		if Input.is_action_pressed("sprint"):
			player_light.texture_scale = 0.7
		else:
			player_light.texture_scale = 0.3
	else:
		player_light.texture_scale = lerp(player_light.texture_scale, 0.01, 0.02)
