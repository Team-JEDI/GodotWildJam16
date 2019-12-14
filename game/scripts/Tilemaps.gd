extends Node2D

var fence_tilemap = preload("res://scenes/Fences.tscn")
var gravestone_tilemap = preload("res://scenes/GraveStones.tscn")
var tree_tilemap = preload("res://scenes/Trees.tscn")
var z_index_child_names : Array = [
	"Walls",
	"GraveStones",
	"Trees"
]
var tilemap_prefabs : Array = [
	fence_tilemap,
	gravestone_tilemap,
	tree_tilemap
]

func _ready():
	for i in z_index_child_names.size():
		var indexing_ledger : Dictionary = {}
		var child = get_node(z_index_child_names[i])
		var cells : Array = child.get_used_cells()
		for cell in cells:
			if not indexing_ledger.has(cell[1]):
				indexing_ledger[cell[1]] = []
			indexing_ledger[cell[1]].append([cell, child.get_cellv(cell)])
		for	z_index in indexing_ledger.keys():
			var new_tilemap = tilemap_prefabs[i].instance()
			if z_index_child_names[i] == "Walls":
				new_tilemap.z_index = z_index * 2 + 2
			else:
				new_tilemap.z_index = z_index + 1
			new_tilemap.cell_size = child.cell_size
			for cell_and_tm_index in indexing_ledger[z_index]:
				new_tilemap.set_cellv(cell_and_tm_index[0], cell_and_tm_index[1])
			add_child(new_tilemap)	
	Events.connect("graph_made", self, "_on_graph_made")			

func _on_graph_made():
	print("graph_made")
	for child_name in z_index_child_names:
		remove_child(get_node(child_name))