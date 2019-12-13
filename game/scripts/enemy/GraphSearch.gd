extends Node

const EDGE_CT : int = 8

var path_ledger : Dictionary
var priority_queue : Array
var max_movement : int

func get_new_path(from_node, to_node, _max_movement) -> Array:
	if from_node == to_node:
		return []
	max_movement = _max_movement
	priority_queue = [from_node]
	path_ledger = {}
	path_ledger[from_node] = [
		null,
		0.0,
		to_node.position.distance_to(from_node.position)
	]
	var success : bool = _generate_shortest_path(from_node, to_node)
	if not success:
		print("no success")
		return []
	return _assemble_generated_path(to_node)	

func _generate_shortest_path(from_node, to_node) -> bool:
	for i in range(EDGE_CT):
		var found_end : bool = _search_one_step(from_node, to_node, i)
		if found_end:
			return true
	priority_queue.pop_front()
	if priority_queue.size() == 0:
		return false
	priority_queue.sort_custom(self, "_first_distance_lesser")
	return _generate_shortest_path(priority_queue[0], to_node)	

func _search_one_step(from_node, to_node, edge_i) -> bool:
	var step_node = from_node.edges[edge_i]
	if step_node != null: # needs other checks
		var step_weight : float = from_node.weights[edge_i]
		var path_weight : float = path_ledger[from_node][1]
		var total_distance : float = step_weight + path_weight
		if step_node == to_node and total_distance <= max_movement:
			path_ledger[to_node] = [from_node, 0.0, 0.0]
			return true
		if total_distance < max_movement:
			var ledger_entry = [
				from_node,
				total_distance,
				to_node.position.distance_to(step_node.position)
			]	
			if path_ledger.has(step_node):
				path_ledger["temp"] = ledger_entry
				if _first_distance_lesser("temp", step_node):
					path_ledger[step_node] = ledger_entry
			else:
				priority_queue.append(step_node)
				path_ledger[step_node] = ledger_entry		
	return false				

func _first_distance_lesser(node_a, node_b) -> bool:
	var distance_a : float = path_ledger[node_a][1] + path_ledger[node_a][2]
	var distance_b : float = path_ledger[node_b][1] + path_ledger[node_b][2]
	return distance_a < distance_b

func _assemble_generated_path(to_node) -> Array:
	var path : Array = [to_node]
	var cur_node = to_node
	var next_node
	while true:
		next_node = path_ledger[cur_node][0]
		if path_ledger[next_node][0] == null:
			break
		else:
			path.append(next_node)	
			cur_node = next_node
	path.invert()		
	return path