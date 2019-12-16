extends KinematicBody2D

const TILE_SIZE := 96.0

enum states {
	FOLLOW,
	IDLE,
}

var state = states.IDLE
var player
var sprite_dir : int = 0
var sprite_angles : Array = [PI/8, 7*PI/8, 9*PI/8, 15*PI/8]
var sprite_dir_to_str_walking : Dictionary = {
	0 : "WalkRight",
	3 : "WalkDown",
	2 : "WalkLeft",
	1 : "WalkDown"
}
var sprite_dir_to_str_idle : Dictionary = {
	0 : "IdleRight",
	3 : "IdleDown",
	2 : "IdleLeft",
	1 : "IdleDown"
}
var move : Vector2

signal noise_made

func _ready():
	$FootSteps.bus = "SFX"

func _physics_process(delta):
	# Handle movement direction
	if state == states.FOLLOW:
		if position.distance_to(player.position) > 96.0:
			move = position - player.position
		else:
			move = Vector2.ZERO	
		_control_sprite_animation()
		z_index = round(position.y / TILE_SIZE)	

func _control_sprite_animation():
	var new_sprite_dir : int
	var moving_angle : float = move.angle()
	if moving_angle < 0:
		moving_angle = 2 * PI + moving_angle
	elif moving_angle > 2 * PI:
		moving_angle = 2 * PI - moving_angle
	var i = 0	
	while i < 4:	
		if moving_angle < sprite_angles[i]:
			new_sprite_dir = i
			break
		i += 1
	if i == 4:
		new_sprite_dir = 0		
	if new_sprite_dir != sprite_dir:
		sprite_dir = new_sprite_dir		
		if move != Vector2.ZERO:
			$AnimationPlayer.play(sprite_dir_to_str_walking[sprite_dir])
		else:	
			$AnimationPlayer.play(sprite_dir_to_str_idle[sprite_dir])

