extends Node2D

const A_LARGE_NUMBER : float = 1000000.0

var node_class = preload("res://scenes/enemy/GraphNode.tscn")
var graph_pos_to_node : Dictionary
var pos_to_node : Dictionary
var test_path : Array = []

func init(floor_cells, wall_cells):
	_make_nodes(floor_cells, wall_cells)
	_connect_nodes()

func get_nearest_node(obj_pos):
	var distance : float
	var shortest_distance : float = A_LARGE_NUMBER
	var node_positions = pos_to_node.keys()
	var nearest_node_pos : Vector2
	for node_pos in node_positions:
		distance = node_pos.distance_to(obj_pos)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_node_pos = node_pos
	return pos_to_node[nearest_node_pos]		

"""
func _process(delta):
	# for _draw() debug
	if Input.is_action_just_pressed("test_next"):
		_get_new_test_path()
"""
	
func _make_nodes(floor_cells, wall_cells):
	var cell_exists_at : Dictionary
	for cell in floor_cells:
		if not cell in wall_cells:
			cell_exists_at[cell] = 1
	var base_offset := Vector2(16, 16)
	var local_node_map : Array
	for cell in cell_exists_at.keys():
		var pos_offset : Vector2 = 96 * cell + base_offset
		var graph_pos_offset : Vector2 = 3 * cell
		local_node_map = _get_local_node_map(cell, cell_exists_at)
		for i in range(3):
			for j in range(3):
				if local_node_map[i][j]:
					var node = node_class.instance()
					var graph_pos := graph_pos_offset + Vector2(i, j)
					node.position = pos_offset + Vector2(i * 32, j * 32)
					node.graph_pos = graph_pos
					graph_pos_to_node[graph_pos] = node
					pos_to_node[node.position] = node
					$Nodes.add_child(node)
					node.hide()

func _get_local_node_map(cell, cell_exists_at) -> Array:
	var local_node_map := [
		[true, true, true],
		[true, true, true],
		[true, true, true]
	]
	var neighbor_cell_exists : bool
	"""
	##############
	# problem code... probably unnecessary anyway.
	##############
	for i in range(-1, 2):
		for j in range(-1, 2):
			if not (i == 0 and j == 0):
				neighbor_cell_exists = cell_exists_at.has(cell + Vector2(i, j))
				if not neighbor_cell_exists:
					if j == 0:
						for k in range(3):
							local_node_map[i + 1][k] = false
					elif i == 0:
						for k in range(3):
							local_node_map[k][j + 1] = false 		
					elif abs(i) == 1 and abs(j) == 1:
						local_node_map[i + 1][j + 1] = false
	"""
	return local_node_map					
				
func _connect_nodes():
	var edges_pos : int
	var sqrt_2 = sqrt(2.0)
	for node in $Nodes.get_children():
		node.edges = [null, null, null, null, null, null, null, null]
		node.weights = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		edges_pos = 0
		for i in range(-1, 2):
			for j in range(-1, 2):
				if not (i == 0 and j == 0):
					var neighbor_node_pos = node.graph_pos + Vector2(i, j)
					if graph_pos_to_node.has(neighbor_node_pos):
						node.edges[edges_pos] = graph_pos_to_node[neighbor_node_pos]
						if abs(i) == 1 and abs(j) == 1:
							node.weights[edges_pos] = sqrt_2
						else:
							node.weights[edges_pos] = 1.0	
					edges_pos += 1

func _draw():
	#_draw_all_edges()
	#_draw_test_path()
	pass

func _draw_all_edges():
	for node in $Nodes.get_children():
		for neighbor in node.edges:
			if neighbor != null:
				draw_line(node.position, neighbor.position, Color(255, 0, 0), 2)

func _draw_test_path():
	for i in range(test_path.size() - 1):
		draw_line(test_path[i].position, test_path[i + 1].position, Color(255, 180, 0), 5)

func _get_new_test_path():
	var nodes : Array = $Nodes.get_children()
	var node_ct : int = nodes.size()
	var start_node = nodes[randi()%node_ct]
	var end_node = nodes[randi()%node_ct]
	test_path = $GraphSearch.get_new_path(start_node, end_node, 600)
	print(test_path)
