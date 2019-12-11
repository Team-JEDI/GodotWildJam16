extends KinematicBody2D
class_name Creature

const CREATURE_SPEED := 85.0       # Movement speed in pixels per second
const SPRINT_FACTOR := 3.5         # How much faster sprinting is than sneaking

enum state {
	PATROLLING,
	CHASING,
	ATTACKING,
	STUNNED
}

var creature_state = state.PATROLLING

signal noise_made

func _ready():
	pass

func _process(delta):
	pass

