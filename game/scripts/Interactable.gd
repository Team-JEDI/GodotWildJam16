extends StaticBody2D

func _process(delta):
	var overlapping_bodies : Array = $InteractionArea.get_overlapping_bodies()
	if overlapping_bodies.size() > 0 and Input.is_action_just_pressed("interact"):
		for body in overlapping_bodies:
			if body.name == "Character": # change to == "Player" or whatever the name ends up being
				print("Interacting with %s" % name)
				$AudioStreamPlayer2D.play() # might need several, such as in open/close door
				# do the interaction things!

func _send_item_to_player():
	pass
	# Events.emit_signal("item_pickup", "item name")

func _take_item_from_player():
	pass
	# Events.emit_signal("item_destroy", "item name")