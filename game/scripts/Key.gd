extends Node2D

var picked_up : bool = false

func _process(delta):
	if not picked_up:
		var overlapping_bodies : Array = $InteractionArea.get_overlapping_bodies()
		if overlapping_bodies.size() > 0:
			for body in overlapping_bodies:
				if body.name == "Character": 
					print("Interacting with %s" % name)
					$AudioStreamPlayer2D.play() 
					Events.emit_signal("item_pickup", "key")
					picked_up = true
					$Sprite.hide()
	elif not $AudioStreamPlayer2D.is_playing():
		queue_free()
