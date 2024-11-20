extends Node2D

@onready var dash_timer = $DashTimer
@onready var dash_snd = $AudioStreamPlayer2D

func start_dash(dur):
	dash_timer.wait_time = dur
	dash_timer.start()
	dash_snd.play()

func is_dashing():
	return !dash_timer.is_stopped()
