extends KinematicBody2D

const WALK_SPEED : float = 80.0
const RUN_SPEED : float = 270.0
const GRAB_DIST : float = 60.0
const LIGHT_FADE_SZ : float = 1000.0
const CHASE_TIMEOUT_DIST : float = 300.0
const CHASE_TIMEOUT_TIME : float = 8.0
const TILE_SIZE : float = 96.0

enum STATES {
	PATROL,
	RETURN_TO_PATROL,
	CHASE,
	SEARCH,
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

func _ready():
	Events.connect("return_path", self, "_store_path")
	Events.connect("return_patrol", self, "_store_patrol")
	Events.emit_signal("get_patrol", _ID)
	chase_end_timer.connect("timeout", self, "_chase_end")
	add_child(chase_end_timer)
	chase_end_timer.set_one_shot(true)
	add_child(get_new_chase_path_timer)
	get_new_chase_path_timer.set_one_shot(true)

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
	elif state == STATES.SEARCH:
		move = _search()
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
	and state != STATES.CHASE \
	and state != STATES.FEAST \
	and state != STATES.STUN:
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
	if just_changed_state:
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
	and position.distance_to(player.position) <= LIGHT_FADE_SZ * echo_scale * 0.6:
		state = STATES.CHASE
		just_changed_state = true

func _chase(delta):
	var move_vec = Vector2.ZERO
	if just_changed_state:
		just_changed_state = false
		print("Enemy %s " % name + "state changed to [chase]")
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
		player.player_state = player.state.STUN
		state = STATES.FEAST
		just_changed_state = true
	return move_vec

func _chase_end():
	state = STATES.RETURN_TO_PATROL
	just_changed_state = true

func _search():
	# no time to do this
	pass

func _feast():
	if just_changed_state:
		print("Enemy %s " % name + "state changed to [feast]")
		just_changed_state = false

func _stun():
	pass