extends StaticBody2D

enum states {
	OPEN,
	CLOSED,
	LOCKED
}

var forget_item_timer := Timer.new()
var recently_used_item : String = ""
var state = states.LOCKED
var prev_state
var player_has_level_end_key : bool = false
onready var collis_shape = get_node("CollisionShape2D")

func _ready():
	_manage_sprites_and_collis()	
	z_index = round(position.y / 96.0)
	Events.connect("use_item", self, "_on_use_item")
	forget_item_timer.connect("timeout", self, "_forget_item")
	forget_item_timer.set_one_shot(true)
	add_child(forget_item_timer)

func _manage_sprites_and_collis():
	if state == states.OPEN:
		remove_child(collis_shape)
		$LockedSprite.hide()
		$UnlockedSprite.hide()
	elif state == states.CLOSED:
		if not get_node("CollisionShape2D"):
			add_child(collis_shape)
		$LockedSprite.hide()
		$UnlockedSprite.show()
		$UnlockedSprite.frame = 0
	elif state == states.LOCKED:
		if not get_node("CollisionShape2D"):
			add_child(collis_shape)
		$UnlockedSprite.hide()
		$LockedSprite.show()	

func _on_use_item(item_name, key_count, has_level_end_key):
	print(item_name + ", " + String(key_count) + ", " + String(has_level_end_key))
	if item_name == "keys" and has_level_end_key:
		recently_used_item = item_name
		player_has_level_end_key = has_level_end_key
		forget_item_timer.start(0.02)

func _forget_item():
	recently_used_item = ""

func _process(delta):
	var overlapping_bodies : Array = $InteractionArea.get_overlapping_bodies()
	if overlapping_bodies.size() > 0:
		for body in overlapping_bodies:
			if body.name == "Character": 
				if Input.is_action_just_pressed("interact"):
					print("Interacting with %s" % name)
					if state == states.OPEN:
						$AnimationPlayer.play("Close")
						$UnlockedSprite.material = null
						state = states.CLOSED
					elif state == states.CLOSED:
						$UnlockedSprite.show()
						$AnimationPlayer.play("Open")
						$UnlockedSprite.material = null
						state = states.OPEN
					elif state == states.LOCKED:
						# make sound
						pass
				elif recently_used_item == "keys" and state == states.LOCKED and player_has_level_end_key:
					state = states.CLOSED
					$UnlockedSprite.material = null
					Events.emit_signal("item_destroy", "level end key")
				break		
	if not $AnimationPlayer.is_playing():				
		if prev_state != state:
			_manage_sprites_and_collis()
		prev_state = state			

	