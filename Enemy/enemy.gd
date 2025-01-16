extends CharacterBody2D

@export var movement_speed = 40.0
@export var hp = 10
@export var knockback_recovery = 3.5
@export var exp = 1
@export var damage = 1
var knockback = Vector2.ZERO

@onready var player = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var snd_hit = $snd_hit
@onready var hit_box = $HitBox
@onready var dmgLbl = %DmgLbl
@onready var dmgTimer = %DmgShowTimer

var death_anim = preload("res://Enemy/explosion.tscn")
var exp_gem = preload("res://Objects/exp_gem.tscn")

signal remove_from_array(object)
signal hurt_received(damage, angle, knockback_amount)

func _ready():
	anim.play("walk")
	hit_box.damage = damage

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)
	var direction = global_position.direction_to(player.global_position).normalized()
	velocity = direction * movement_speed
	velocity += knockback
	move_and_slide()

	if direction.x > 0.1:
		sprite.flip_h = true
	elif direction.x < -0.1:
		sprite.flip_h = false

func death():
	emit_signal('remove_from_array', self)
	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.exp = exp
	loot_base.call_deferred("add_child", new_gem)

	global_position = Vector2(1000,1000)

func _on_hurt_box_hurt(damage, angle, knockback_amount):
	var player_position = player.global_position
	var enemy_position = global_position
	var direction = global_position.direction_to(player.global_position).normalized()

	var tween = create_tween()
	var tween2 = create_tween()

	angle = - enemy_position.direction_to(player_position)

	dmgTimer.start()
	dmgLbl.text = str(damage)

	if direction.x >= 0:
		tween.tween_property(dmgLbl, "position",dmgLbl.position + Vector2(0.05, -1.5), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween2.tween_property(dmgLbl, "scale",Vector2(1.1, 1.1), 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		dmgLbl.scale = Vector2(0.5, 0.5)

	elif direction.x < 0:
		tween.tween_property(dmgLbl, "position",dmgLbl.position + Vector2(-0.15, -1.5), 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween2.tween_property(dmgLbl, "scale",Vector2(1.1, 1.1), 0.4).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.play()
		dmgLbl.scale = Vector2(0.5, 0.5)

	hp -= damage
	knockback =  angle.normalized() * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
		emit_signal("hurt_received", damage, angle.normalized(), knockback_amount)

func _on_dmg_show_timer_timeout():
	dmgLbl.text = ""
	dmgTimer.start()
