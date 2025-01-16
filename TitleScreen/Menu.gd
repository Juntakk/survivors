extends Control

var level = "res://World/world.tscn"

func _on_quit_btn_pressed():
	get_tree().quit()


func _on_play_btn_pressed():
	get_tree().change_scene_to_file(level)
