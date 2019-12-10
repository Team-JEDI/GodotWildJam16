extends Node2D

const EXPAND_DURATION = 0.05
const FADE_DURATION = 3.0

func trigger_echo(echo_size : float):
	
	# Echo quickly expands from initial position
	$Tween.interpolate_property($Light2D, "texture_scale", 0.01, echo_size, EXPAND_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	# Echo slowly fades to black
	$Tween.interpolate_property($Light2D, "energy", 1.0, 0.0, FADE_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	
	# Clear echo from level
	queue_free()
