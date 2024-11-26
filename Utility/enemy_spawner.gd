extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

@export var time = 0
@onready var background = $"../Background"

signal change_time(time)

func _ready():
	connect("change_time", Callable(player, "change_time"))

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns

	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter < i.enemy_num:
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
	emit_signal("change_time", time)

func get_random_position():
	# Use the region rect if region_enabled; otherwise, fallback to full texture size
	var region = background.region_rect if background.region_enabled else Rect2(Vector2.ZERO, background.texture.get_size())

	# Correct for centered offset
	var half_size = (region.size * background.global_scale) / 2.0
	var center = (background.global_transform.origin + (region.position * background.global_scale)) + Vector2(4000,4000)

	# Calculate top-left and bottom-right corners
	var top_left = center - half_size + Vector2(50, 50)
	var bottom_right = center + half_size - Vector2(50, 50)

	# Generate a random position within these bounds
	var x_spawn = randf_range(top_left.x, bottom_right.x)
	var y_spawn = randf_range(top_left.y, bottom_right.y)

	return Vector2(x_spawn, y_spawn)


