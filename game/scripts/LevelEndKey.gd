extends Node2D

func _process(delta):
	var overlapping_bodies : Array = $InteractionArea.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		for body in overlapping_bodies:
			if body.name == "Character": 
				print("Interacting with %s" % name)
				$AudioStreamPlayer2D.play() 
				Events.emit_signal("item_pickup", "level end key")
				queue_free()
