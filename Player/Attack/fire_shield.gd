extends Area2D

var level = 1
var damage = 5
var attack_size = 1.0
var damageSize = 0.75
var total_dmg = 0

@onready var player = get_tree().get_first_node_in_group("player")


func _ready():
	set_properties_by_level()

	global_position = player.global_position + Vector2(0,3)
	$AnimatedSprite2D.scale = Vector2(attack_size, attack_size)
	$CollisionShape2D.scale = Vector2(damageSize, damageSize)
	$AnimatedSprite2D.play("base")
	

func _process(delta):
	$AnimatedSprite2D.scale = Vector2(attack_size, attack_size)
	$CollisionShape2D.scale = Vector2(damageSize, damageSize)

func set_properties_by_level():
	match level:
		1:	
			damage = 5
			attack_size = 1 * (1 + player.spell_size)
			damageSize = 0.75 * (1 + player.spell_size)
		2:	
			damage = 5
			attack_size = 2 * (1 + player.spell_size)
			damageSize = 1.5 * (1 + player.spell_size)
		3:	
			damage = 8
			attack_size = 3 * (1 + player.spell_size)
			damageSize = 2.25 * (1 + player.spell_size)
			
		4:	
			damage = 5
			attack_size = 4 * (1 + player.spell_size)
			damageSize = 3 * (1 + player.spell_size)
			
