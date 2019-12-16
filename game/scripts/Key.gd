extends Node2D

signal key_noise_made

var picked_up : bool = false
var hum_delay_timer := Timer.new()

func _ready():
	Events.connect("use_item", self, "_on_use_item")
	hum_delay_timer.connect("timeout", self, "_on_hum_delay_timer_timeout")
	hum_delay_timer.set_one_shot(true)
	add_child(hum_delay_timer)
	$AudioStreamPlayer2D.bus = "SFX"
	$Hum.bus = "SFX"

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

func _on_use_item(holding_item, key_ct, has_level_end_key):
	if holding_item == "bell":
		hum_delay_timer.start(1.0)

func _on_hum_delay_timer_timeout():
	emit_signal("key_noise_made", 0.8, position)
	$Hum.play()