extends Area2D

signal game_saved

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	if body is Player:
		emit_signal("game_saved")
		# TODO: add some effect to let the player know the checkpoint is active
