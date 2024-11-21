extends Area2D

var level = 1
var damage = 5
var attack_size = 1.0
var damageSize = 0.75
var total_dmg = 0
var knockback_amount = 200

var base_angle = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	base_angle = global_position.direction_to(Vector2(0, 1))
	set_properties_by_level()
	global_position = player.global_position + Vector2(0,3)
	$AnimatedSprite2D.scale = Vector2(attack_size, attack_size)
	$CollisionShape2D.scale = Vector2(damageSize, damageSize)
	$AnimatedSprite2D.play("base")

	for node in get_tree().get_nodes_in_group("enemy"):
		if node is CharacterBody2D and node.has_signal("hurt_received"):
			node.connect("hurt_received", Callable(self, "_on_enemy_hurt"))
	print(base_angle)
func _process(_delta):
	global_position = player.global_position + Vector2(0,3)

func _on_enemy_hurt(damage, angle, knockback_amount):
	base_angle = angle

func set_properties_by_level():
	match level:
		1:
			damage = 4
			knockback_amount = 200
			attack_size = 1 * (1 + player.spell_size)
			damageSize = 0.75 * (1 + player.spell_size)
		2:
			damage = 7
			knockback_amount = 200
			attack_size = 2 * (1 + player.spell_size)
			damageSize = 1.5 * (1 + player.spell_size)
		3:
			damage = 9
			knockback_amount = 200
			attack_size = 3 * (1 + player.spell_size)
			damageSize = 2.25 * (1 + player.spell_size)
		4:
			damage = 12
			knockback_amount = 200
			attack_size = 4 * (1 + player.spell_size)
			damageSize = 3 * (1 + player.spell_size)
