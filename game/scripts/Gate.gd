extends StaticBody2D

export var init_state : String = "closed"
export var openable : bool = true

enum states {
	OPEN,
	CLOSED,
	LOCKED
}

var forget_item_timer := Timer.new()
var recently_used_item : String = ""
var state 
var prev_state
onready var collis_shape = get_node("CollisionShape2D")

func _ready():
	if init_state == "open":
		state = states.OPEN
	elif init_state == "closed":
		state = states.CLOSED	
	elif init_state == "locked":	
		state = states.LOCKED
	else:
		print("gate %s " %name + " given invalide init_state %s" %init_state)	
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
	if key_count > 0 and item_name == "keys":
		recently_used_item = item_name
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
					elif state == states.CLOSED and openable:
						$UnlockedSprite.show()
						$AnimationPlayer.play("Open")
						$UnlockedSprite.material = null
						state = states.OPEN
					elif state == states.LOCKED:
						# make sound
						pass
				elif recently_used_item == "keys" and state == states.LOCKED:
					state = states.CLOSED
					$UnlockedSprite.material = null
					Events.emit_signal("item_destroy", "key")
				break		
	if not $AnimationPlayer.is_playing():				
		if prev_state != state:
			_manage_sprites_and_collis()
		prev_state = state			

