extends StaticBody2D

@onready var baseColor = $Sprite2D.self_modulate

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hurt_box_area_entered(area):
	if area.is_in_group("attack"):
		$Sprite2D.self_modulate = Color(2,3,4,5)
		$TreeHitTimer.start()
		print("tree hit")


func _on_tree_hit_timer_timeout():
	$Sprite2D.self_modulate = baseColor
