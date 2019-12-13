extends KinematicBody2D

const WALK_SPEED : float = 80.0
const RUN_SPEED : float = 300.0
const LIGHT_FADE_SZ : float = 1000.0

enum STATES {
	patrol,
	return_to_patrol,
	chase,
	search,
	feast,
	stun
}

export var _ID : int = 0

var character
var state = STATES.return_to_patrol
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

func _store_patrol(_id, _patrol_multipath):
	if _id == _ID:
		patrol_multipath = _patrol_multipath

func _store_path(_id, _path):
	if _id == _ID:
		cur_path = _path

func _physics_process(delta):
	if state == STATES.patrol:
		move = _patrol(delta)
	elif state == STATES.return_to_patrol:
		move = _return_to_patrol(delta)	
	elif state == STATES.chase:
		move = _chase(delta)
	elif state == STATES.search:
		move = _search()
	elif state == STATES.feast:
		_feast()
	elif state == STATES.stun:
		_stun()
	else:
		print("**Error** Monster state is " + String(state))	
		print("This is a non-state.")
	_control_anim_direction()	
	move_and_slide(move)

func _control_anim_direction():
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
		cur_path = []
		cur_node = 0
		Events.emit_signal("get_path", _ID, position, patrol_multipath[cur_patrol_path][cur_patrol_node].position)
	if cur_path.size() > 0:
		var target_node = cur_path[cur_node]
		move_vec = _get_move_to_node(target_node, WALK_SPEED, delta, "return")
		if cur_node == cur_path.size():
			state = STATES.patrol
			just_changed_state = true
	return move_vec		

func _on_noise_made(echo_scale, location):
	if state != STATES.chase and position.distance_to(character.position) <= LIGHT_FADE_SZ * echo_scale * 0.7:
		state = STATES.chase
		just_changed_state = true

func _chase(delta):
	var move_vec = Vector2.ZERO
	if just_changed_state:
		just_changed_state = false
		print("Enemy %s " % name + "state changed to [chase]")
	cur_path = []
	cur_node = 0
	if position.distance_to(character.position) > RUN_SPEED * delta + 100:
		Events.emit_signal("get_path", _ID, position, character.position)
		if cur_path.size() > 0:
			var target_node = cur_path[cur_node]	
			move_vec = _get_move_to_node(target_node, RUN_SPEED, delta, "chase")
	return move_vec

func _search():
	pass

func _feast():
	pass

func _stun():
	pass