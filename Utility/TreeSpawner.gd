extends Node2D

@onready var tree_spawns= []

@onready var player = get_tree().get_first_node_in_group("player")
@onready var tree = preload("res://Objects/tree.tscn")

func _ready():
	randomize()
	spawn_trees(100)

func spawn_trees(total):
	for i in range(total):
		var tree_instance = tree.instantiate()
		tree_instance.global_position = spawn_tree()
		add_child(tree_instance)
		tree_spawns.append(tree_instance)

		if i % 10 == 0:
			await get_tree().process_frame

func spawn_tree():
	var randX = player.global_position.x + randf_range(-1900, 1900)
	var randY = player.global_position.y + randf_range(-1900, 1900)
	return Vector2(randX, randY)
