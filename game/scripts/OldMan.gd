extends KinematicBody2D

const TILE_SIZE := 96.0

enum states {
	FOLLOW,
	IDLE,
	STILL
}

var state = states.FOLLOW
var player
var sprite_dir : int = 0
var sprite_angles : Array = [PI/8, 7*PI/8, 9*PI/8, 15*PI/8]
var sprite_dir_to_str_walking : Dictionary = {
	0 : "WalkRight",
	3 : "WalkDown",
	2 : "WalkLeft",
	1 : "WalkUp"
}
var sprite_dir_to_str_idle : Dictionary = {
	0 : "IdleRight",
	3 : "IdleDown",
	2 : "IdleLeft",
	1 : "IdleUp"
}
var move : Vector2

signal noise_made

func _ready():
	$FootSteps.bus = "SFX"
	Events.connect("old_man_wait", self, "_on_old_man_wait")
	Events.connect("old_man_follow", self, "_on_old_man_follow")

func _physics_process(delta):
	# Handle movement direction
	if state == states.FOLLOW or state == states.IDLE:
		if position.distance_to(player.position) > 200.0 and state == states.IDLE:
			state = states.FOLLOW
		elif position.distance_to(player.position) < 96.0 and state == states.FOLLOW:
			state = states.IDLE	
		if state == states.FOLLOW:
			move = player.position - position	
		else:
			move = Vector2.ZERO	
		_control_sprite_animation()
		move_and_slide(move.normalized() * 240)
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

func _on_old_man_wait():
	state = states.STILL
	$AnimationPlayer.stop()
	$Sprite.frame = 26

func _on_old_man_follow():
	state = states.IDLE