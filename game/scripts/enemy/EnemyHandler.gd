extends Node2D

const MAX_MOVEMENT : float = 500.0

var patrols : Dictionary

func _ready():
	var tilemaps = get_parent().get_node("Tilemaps")
	var tm_floor = tilemaps.get_node("Floor")
	var tm_wall = tilemaps.get_node("Walls")
	$EnemyGraph.init(tm_floor.get_used_cells(), tm_wall.get_used_cells(), tm_wall)
	Events.connect("get_path", self, "_get_and_emit_path")
	Events.connect("get_patrol", self, "_get_and_emit_patrol")
	var enemies : Array = $Enemies.get_children()
	var enemy_ct : int = enemies.size()
	var character = get_parent().get_node("Character")
	for i in range(enemy_ct):
		enemies[i].player = character
		character.connect("noise_made", enemies[i], "_on_noise_made")
		_get_and_emit_patrol(i)
	Events.emit_signal("graph_made")	

func _process(delta):
	# only need to call update() if showing patrol paths
	# update()
	pass

func _get_and_emit_path(_id, from_pos, to_pos):
	var node_a = $EnemyGraph.get_nearest_node(from_pos)
	var node_b = $EnemyGraph.get_nearest_node(to_pos)
	var path = $EnemyGraph/GraphSearch.get_new_path(node_a, node_b, MAX_MOVEMENT)
	Events.emit_signal("return_path", _id, path)

func _get_and_emit_patrol(_id):
	var patrol_nodes : Array = $EnemyPatrols.get_child(_id).get_children()
	var patrol_node_ct : int = patrol_nodes.size()
	var patrol : Array = []
	var path : Array
	var node_a
	var node_b
	for i in range(patrol_node_ct):
		node_a = $EnemyGraph.get_nearest_node(patrol_nodes[i].position)
		if i == patrol_node_ct - 1:
			node_b = $EnemyGraph.get_nearest_node(patrol_nodes[0].position)
		else:
			node_b = $EnemyGraph.get_nearest_node(patrol_nodes[i + 1].position)
		path = $EnemyGraph/GraphSearch.get_new_path(node_a, node_b, MAX_MOVEMENT)	
		patrol.append(path)
	patrols[_id] = patrol		
	Events.emit_signal("return_patrol", _id, patrol)

"""
func _draw():
	_show_patrols()
"""

func _show_patrols():
	for enemy_id in patrols.keys():
		var patrol = patrols[enemy_id]
		for path in patrol:
			for node_i in range(path.size() - 1):
				draw_line(path[node_i].position, path[node_i + 1].position, Color(0, 0, 255), 4)
