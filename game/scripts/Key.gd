extends Node2D

func _process(delta):
	var overlapping_bodies : Array = $InteractionArea.get_overlapping_bodies()
	if overlapping_bodies.size() > 0 and Input.is_action_just_pressed("interact"):
		for body in overlapping_bodies:
			if body.name == "Character": 
				print("Interacting with %s" % name)
				$AudioStreamPlayer2D.play() 
				Events.emit_signal("item_pickup", "key")
				queue_free()
