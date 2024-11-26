extends Area2D

@export var exp = 1

var spr_green = preload("res://Textures/Items/Gems/Gem_green.png")
var spr_blue = preload("res://Textures/Items/Gems/Gem_blue.png")
var spr_red = preload("res://Textures/Items/Gems/Gem_red.png")
var food = preload("res://Textures/FOOD.png")
var magnet = preload("res://Objects/magnet.png")

var target = null
var speed = -2
var healthGained = 25

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected
@onready var soundMagnet = $MagnetCollected
@onready var soundFood = $food_snd

@onready var playerGrabArea = get_tree().get_first_node_in_group("playerGrabArea")
@onready var player = get_tree().get_first_node_in_group("player")

@onready var healthGainLbl = %health_gain_lbl
@onready var foodLblTimer = %FoodLblTimer

func _ready():
	if random_chance():
		sprite.texture = magnet
		sprite.scale = Vector2(0.66, 0.66)
	if exp < 5:
		null
	elif exp < 25:
		sprite.texture = spr_blue
	elif exp > 9999:
		sprite.texture = food
		sprite.scale *= 1.05
		exp = 0
	else:
		sprite.texture = spr_red

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 6.5 * delta

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
	if sprite.texture == food:
		player.hp += healthGained
		soundFood.play()
		healthGainLbl.visible = true
		healthGainLbl.text = str("+", healthGained)
		healthGainLbl.global_position = player.global_position - Vector2(0, 20)
		foodLblTimer.start()
		collision.call_deferred("set", "disabled", true)
		return 0
	else:
		sound.play()
		collision.call_deferred("set", "disabled", true)
		sprite.visible = false
		return exp

func _on_test_timer_timeout():
	playerGrabArea.scale = Vector2(1, 1)
	queue_free()



func _on_food_lbl_timer_timeout():
	healthGainLbl.visible = false
