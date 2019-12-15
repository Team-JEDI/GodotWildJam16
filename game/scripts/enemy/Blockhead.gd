extends KinematicBody2D

signal enemy_noise_made

const WALK_SPEED : float = 80.0
const RUN_SPEED : float = 270.0
const GRAB_DIST : float = 60.0
const LIGHT_FADE_SZ : float = 1000.0
const CHASE_TIMEOUT_DIST : float = 300.0
const CHASE_TIMEOUT_TIME : float = 8.0
const TILE_SIZE : float = 96.0
const IDLE_SOUND_TIME_FACTOR : float = 3.0
const MIN_IDLE_SOUND_TIME : float = 7.0

enum STATES {
	PATROL,
	RETURN_TO_PATROL,
	CHASE,
	FEAST,
	STUN
}

export var _ID : int = 0

var state = STATES.RETURN_TO_PATROL
var player
var get_new_chase_path_timer := Timer.new()
var chase_end_timer := Timer.new()
var patrol_multipath : Array = []
var cur_patrol_path : int = 0
var cur_patrol_node : int = 0
var cur_path : Array 
var cur_node : int = 0
var move : Vector2
var just_changed_state : bool = true
var sprite_dir : int = 0
var sprite_angles : Array = [PI/8, 7*PI/8, 9*PI/8, 15*PI/8]
var sprite_dir_to_str : Dictionary = {
	0 : "FaceRight",
	3 : "FaceUp",
	2 : "FaceLeft",
	1 : "FaceDown"
}
var sting_fadeout_timer := Timer.new()
var stun_timer := Timer.new()

var idle_sounds : Array = [
	preload("res://assets/sounds/Monster_Idle_1.ogg"),
	preload("res://assets/sounds/Monster_Idle_2.ogg"),
	preload("res://assets/sounds/Monster_Idle_3.ogg"),
	preload("res://assets/sounds/Monster_Idle_4.ogg"),
]
var chase_sound_loop = preload("res://assets/sounds/Monster_Chase_LOOP.ogg")
var devouring_sound_loop = preload("res://assets/sounds/Monster_Devouring_LOOP.ogg")

var idle_sound_timer := Timer.new()

func _ready():
	Events.connect("return_path", self, "_store_path")
	Events.connect("return_patrol", self, "_store_patrol")
	Events.emit_signal("get_patrol", _ID)
	chase_end_timer.connect("timeout", self, "_chase_end")
	add_child(chase_end_timer)
	chase_end_timer.set_one_shot(true)
	add_child(get_new_chase_path_timer)
	get_new_chase_path_timer.set_one_shot(true)
	sting_fadeout_timer.set_one_shot(true)
	add_child(sting_fadeout_timer)
	sting_fadeout_timer.connect("timeout", self, "_on_sting_fadeout_timer_timeout")
	stun_timer.set_one_shot(true)
	add_child(stun_timer)
	stun_timer.connect("timeout", self, "_on_stun_timeout")
	idle_sound_timer.set_one_shot(true)
	idle_sound_timer.connect("timeout", self, "_on_idle_sound_timer_timeout")
	add_child(idle_sound_timer)

func _store_patrol(_id, _patrol_multipath):
	if _id == _ID:
		patrol_multipath = _patrol_multipath

func _store_path(_id, _path):
	if _id == _ID:
		cur_node = 0
		cur_path = _path

func _physics_process(delta):
	if state == STATES.PATROL:
		move = _patrol(delta)
	elif state == STATES.RETURN_TO_PATROL:
		move = _return_to_patrol(delta)	
	elif state == STATES.CHASE:
		move = _chase(delta)
	elif state == STATES.FEAST:
		_feast()
		move = Vector2.ZERO
	elif state == STATES.STUN:
		_stun()
		move = Vector2.ZERO
	else:
		print("**Error** Monster state is " + String(state))	
		print("This is a non-state.")
	if player.position.distance_to(position) <= GRAB_DIST * 2 \
	and (state == STATES.PATROL \
		or state == STATES.RETURN_TO_PATROL):
		state = STATES.CHASE	
		just_changed_state = true
	_control_sprite_animation()	
	move_and_slide(move)
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
		$AnimationPlayer.play(sprite_dir_to_str[sprite_dir])

func _get_move_to_node(target_node, speed, delta, mode):
	var distance_to_next_node = position.distance_to(target_node.position)	
	var move_vec : Vector2 = (target_node.position - position).normalized() * speed 
	if distance_to_next_node < speed * delta:
		if mode == "patrol":
			cur_patrol_node += 1
		else:
			cur_node += 1	
	return move_vec

func _patrol(delta):
	var move_vec = Vector2.ZERO
	if just_changed_state:
		idle_sound_timer.start(randf() * IDLE_SOUND_TIME_FACTOR + MIN_IDLE_SOUND_TIME)
		just_changed_state = false
		print("Enemy %s " % name + "state changed to [patrol]")
	if patrol_multipath.size() > 0:
		if cur_patrol_node == patrol_multipath[cur_patrol_path].size() - 1:
			cur_patrol_path += 1
			cur_patrol_node = 0
		if cur_patrol_path == patrol_multipath.size():
			cur_patrol_path = 0
		var target_node = patrol_multipath[cur_patrol_path][cur_patrol_node]	
		move_vec = _get_move_to_node(target_node, WALK_SPEED, delta, "patrol")
	return move_vec

func _return_to_patrol(delta):
	var move_vec = Vector2.ZERO
	MusicAndAmbience.stop_music()
	if just_changed_state:
		idle_sound_timer.start(randf() * IDLE_SOUND_TIME_FACTOR + MIN_IDLE_SOUND_TIME)
		just_changed_state = false
		print("Enemy %s " % name + "state changed to [return to patrol]")
		Events.emit_signal("get_path", _ID, position, patrol_multipath[cur_patrol_path][cur_patrol_node].position)
	if cur_path.size() > cur_node:
		var target_node = cur_path[cur_node]
		move_vec = _get_move_to_node(target_node, WALK_SPEED, delta, "return")
		if cur_node == cur_path.size():
			state = STATES.PATROL
			just_changed_state = true
	return move_vec		

func _on_noise_made(echo_scale, location):
	if state != STATES.CHASE \
	and state != STATES.FEAST \
	and state != STATES.STUN \
	and position.distance_to(player.position) <= LIGHT_FADE_SZ * echo_scale * 0.48:
		state = STATES.CHASE
		just_changed_state = true

func _chase(delta):
	var move_vec = Vector2.ZERO
	if just_changed_state:
		MusicAndAmbience.play_song("chase")
		MusicAndAmbience.play_sting("scare")
		sting_fadeout_timer.start(2.0)
		just_changed_state = false
		print("Enemy %s " % name + "state changed to [chase]")
		$AudioStreamPlayer2D.set_stream(chase_sound_loop)
		$AudioStreamPlayer2D.play()
	var distance_to_player : float = position.distance_to(player.position)
	if distance_to_player > RUN_SPEED * delta + GRAB_DIST:
		if distance_to_player >= CHASE_TIMEOUT_DIST:
			if chase_end_timer.is_paused():
				chase_end_timer.set_paused(false)
				chase_end_timer.start(CHASE_TIMEOUT_TIME)
		elif not chase_end_timer.is_paused():	
			chase_end_timer.set_paused(true)
		if get_new_chase_path_timer.is_stopped():	
			Events.emit_signal("get_path", _ID, position, player.position)
			get_new_chase_path_timer.start(0.2)
		if cur_path.size() > cur_node:
			var target_node = cur_path[cur_node]	
			move_vec = _get_move_to_node(target_node, RUN_SPEED, delta, "chase")
	else:		
		state = STATES.FEAST
		just_changed_state = true
	return move_vec

func _chase_end():
	$AudioStreamPlayer2D.stop()
	MusicAndAmbience.stop_music()
	MusicAndAmbience.play_sting("unsettling")
	sting_fadeout_timer.start(5.0)
	state = STATES.RETURN_TO_PATROL
	just_changed_state = true

func _feast():
	if just_changed_state:
		$AudioStreamPlayer2D.set_stream(devouring_sound_loop)
		$AudioStreamPlayer2D.play()
		player.player_state = player.state.STUN
		print("Enemy %s " % name + "state changed to [feast]")
		just_changed_state = false
	elif player.you_mashed_well_son == true:
		$AudioStreamPlayer2D.stop()
		print("you mashed well, son")
		player.you_mashed_well_son = false
		state = STATES.STUN	
		just_changed_state = true

func _stun():
	if just_changed_state:
		print("Enemy %s " % name + "state changed to [stun]")
		MusicAndAmbience.play_song("post chase")
		stun_timer.start(5.0)
		just_changed_state = false

func _on_sting_fadeout_timer_timeout():
	MusicAndAmbience.fade_out_current_sting()

func _on_stun_timeout():
	MusicAndAmbience.play_sting("unsettling")
	sting_fadeout_timer.start(3.0)
	state = STATES.RETURN_TO_PATROL
	just_changed_state = true

func _on_idle_sound_timer_timeout():
	if state == STATES.PATROL or state == STATES.RETURN_TO_PATROL:
		print("enemy making sound")
		emit_signal("enemy_noise_made", 0.7, position)
		$AudioStreamPlayer2D.set_stream(idle_sounds[randi()%4])
		$AudioStreamPlayer2D.play()
		idle_sound_timer.start(randf() * IDLE_SOUND_TIME_FACTOR + MIN_IDLE_SOUND_TIME)