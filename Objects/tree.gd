extends StaticBody2D

var hp = 10
@onready var dmgLbl = %DmgLbl
@onready var dmgTimer = %DmgShowTimer
@onready var baseColor = $Sprite2D.self_modulate
@onready var gem = preload("res://Objects/exp_gem.tscn")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var hit_snd = $snd_hit
@onready var tree = preload("res://Objects/tree.tscn")

var trees = []

func _ready():
	randomize()
	for i in range(100):
		var tree_instance = tree.instantiate()
		trees.append(tree_instance)
	spawn_trees()

func _process(delta):
	pass

func spawn_trees():
	for tree in trees:
		var random_position_x = randi_range(-3000, 3000)
		var random_position_y = randi_range(-3000, 3000)
		tree.global_position = Vector2(random_position_x, random_position_y)

func _on_tree_hit_timer_timeout():
	$Sprite2D.self_modulate = baseColor

func _on_hurt_box_hurt(damage, angle, knockback):
	hp -= damage
	if hp <= 0:
		dmgTimer.wait_time = 0.05
	var tween = create_tween()
	dmgTimer.start()
	%DmgLbl.text = str(damage)
	tween.tween_property(dmgLbl, "position",dmgLbl.position + Vector2(0.05, -1.5), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	dmgLbl.scale = Vector2(1, 1)
	hit_snd.play()
	$Sprite2D.self_modulate = Color(255,255,255,255)
	$TreeHitTimer.start()

func _on_dmg_show_timer_timeout():
	dmgLbl.text = ""
	dmgTimer.start()

	if hp <= 0:
		queue_free()
		var gem_instance = gem.instantiate()
		gem_instance.global_position = global_position
		gem_instance.exp = 99999
		loot_base.call_deferred("add_child", gem_instance)

