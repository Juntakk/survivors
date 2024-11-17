extends Area2D

@export var exp = 1

var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")
var magnet = preload("res://Objects/magnet.png")

var target = null
var speed = -1.75

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected
@onready var soundMagnet = $MagnetCollected

@onready var playerGrabArea = get_tree().get_first_node_in_group("playerGrabArea")

func _ready():
	if random_chance():
		sprite.texture = magnet
		sprite.scale = Vector2(0.66, 0.66)
	if exp < 5:
		null
	elif exp < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 5.5 * delta

func random_chance():
	var chance = randi() % 100 + 1
	return chance <= 1

func collect():
	if sprite.texture == magnet:
		$TestTimer.start()
		soundMagnet.play()
		playerGrabArea.scale = Vector2(1000, 1000)
		exp = 0
		collision.call_deferred("set", "disabled", true)
		sprite.visible = false
		return exp
	else:
		sound.play()
		collision.call_deferred("set", "disabled", true)
		sprite.visible = false
		return exp

func _on_test_timer_timeout():
	playerGrabArea.scale = Vector2(1, 1)
	queue_free()

