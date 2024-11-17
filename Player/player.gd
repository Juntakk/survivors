extends CharacterBody2D

var normal_move_speed = 100.0
var dash_speed = 500
var dash_length = 0.1
var hp = 80
var maxhp = 80
var last_movement = Vector2.UP

var exp = 0
var exp_level = 1
var collected_exp = 0
var time = 0

#Attacks
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")
var tornado = preload("res://Player/Attack/tornado.tscn")
var javelin = preload("res://Player/Attack/javelin.tscn")
var fireShield = preload("res://Player/Attack/fire_shield.tscn")

#Attack Nodes
@onready var iceSpearTimer = get_node("%IceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%IceSpearAttackTimer")
@onready var tornadoTimer = get_node("%TornadoTimer")
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")
@onready var javelinBase = get_node("%JavelinBase")
@onready var fireShieldBase = get_node("%FireShieldBase")

#IceSpear
var icespear_ammo = 0
var icespear_baseammo = 0
var icespear_attackspeed = 1.5
var icespear_level = 0
var icespear_total_dmg = 0

#FireShield
var fireshield_level = 0

#Tornado
var tornado_ammo = 0
var tornado_baseammo = 0
var tornado_attackspeed = 3
var tornado_level = 0

#Javelin
var javelin_ammo = 0
var javelin_level = 0

var enemy_close = []

@onready var sprite = $Sprite2D
@onready var walk_timer = get_node("%WalkTimer")

#GUI
@onready var exp_bar = get_node("%ExpBar")
@onready var lbl_lvl = get_node("%lbl_lvl")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var health_bar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLoss = get_node("%snd_loss")

@onready var quitBtn = get_node("%QuitBtn")
@onready var backBtn = get_node("%BackBtn")
@onready var menuPanel = get_node("%MenuPanel")
@onready var hoverSnd = "res://Audio/GUI/hover.wav"
@onready var clickSnd = "res://Audio/GUI/click.wav"
@onready var pauseTimer = $GUILayer/GUI/MenuPanel/UnpauseTimer
@onready var titleScreen = preload("res://TitleScreen/menu.tscn") as PackedScene

@onready var dash = $Dash

signal playerdeath

@onready var spear_dmg_lbl = get_node("%SpearDmgLbl")

#Upgrades
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cd = 0
var spell_size = 0
var additional_attacks = 0
var fireshield_spawn = null


func _ready():
	upgrade_character("icespear1")
	attack()
	set_expbar(exp, calculate_exp_cap())
	_on_hurt_box_hurt(0,0,0)
	get_tree().paused = true
	$GUILayer/GUI/LevelChoices.visible = true


func _process(_delta):
	health_bar.value = hp

func _physics_process(_delta):
	movement()
	
func attack():
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1 - spell_cd)
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()
			
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1 - spell_cd)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()			
	
	if javelin_level > 0:
		spawn_javelin()
		
	if fireshield_level > 0:
		spawn_fireshield(fireshield_level)
			
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	
	if Input.is_action_just_pressed("dash"):
		dash.start_dash(dash_length)
	var move_speed = dash_speed if dash.is_dashing() else normal_move_speed
	
	#Flip character
	if mov.x > 0:
		sprite.flip_h = true
	elif mov.x < 0:
		sprite.flip_h = false
	
	#Walking animation
	if mov != Vector2.ZERO:
		last_movement = mov
		if walk_timer.is_stopped():
			if sprite.frame >= sprite.hframes -1:
				sprite.frame = 0
			else: 
				sprite.frame += 1
			walk_timer.start()
	
	velocity = mov.normalized() * move_speed
	move_and_slide()
	
	
func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= clamp(damage - armor, 1.0, 999.0)
	health_bar.max_value = maxhp
	health_bar.value = hp
	if hp <= 0:
		death()

func _on_ice_spear_timer_timeout():
	icespear_ammo += icespear_baseammo + additional_attacks
	iceSpearAttackTimer.start()
	
func _on_ice_spear_attack_timer_timeout():
	if icespear_ammo > 0:
		var icespear_attack = iceSpear.instantiate()
		icespear_attack.position = position
		icespear_attack.target = get_random_target()
		icespear_attack.level = icespear_level
		
		if icespear_attack.level >= 3:
			icespear_attack.damage = 8
			
		spear_dmg_lbl.text =str(icespear_total_dmg)
		icespear_total_dmg += icespear_attack.damage
		
		add_child(icespear_attack)
		
		icespear_ammo -= 1
		if icespear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
			
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP
		
func _on_enemy_detecion_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)
		
func _on_enemy_detecion_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_tornado_timer_timeout():
	tornado_ammo += tornado_baseammo + additional_attacks
	tornadoAttackTimer.start()

func _on_tornado_attack_timer_timeout():
	if tornado_ammo > 0:
		var tornado_attack = tornado.instantiate()
		tornado_attack.position = position
		tornado_attack.last_movement = last_movement
		tornado_attack.level = tornado_level
		add_child(tornado_attack)
		
		tornado_ammo -= 1
		if tornado_ammo > 0:
			tornadoAttackTimer.start()
		else:
			tornadoAttackTimer.stop()
			
func spawn_fireshield(level = 0):
	$Attack/ShieldAttackTimer.start()
	
	if fireshield_spawn != null:
		fireshield_spawn.queue_free()
		fireshield_spawn = null
	
	if fireshield_spawn == null:
		fireshield_spawn = fireShield.instantiate()
		fireShieldBase.add_child(fireshield_spawn)
	fireshield_spawn.level = level
	fireshield_spawn.set_properties_by_level()
		
func _on_shield_attack_timer_timeout():
	if fireshield_spawn != null:
		fireshield_spawn.level = fireshield_level
		fireshield_spawn.queue_free()
		fireshield_spawn = null
		spawn_fireshield(fireshield_level)
		
func spawn_javelin():
	var get_javelin_total = javelinBase.get_child_count()
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position
		javelinBase.add_child(javelin_spawn)
		calc_spawns -= 1
		
	#Update Javelin
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()
			
func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_exp(gem_exp)

func calculate_exp(gem_exp):
	var exp_req = calculate_exp_cap()
	collected_exp += gem_exp
	if exp + collected_exp >= exp_req: #lvl up
		collected_exp -= exp_req - exp
		exp_level += 1
		lbl_lvl.text = str("Level: ", exp_level)
		exp = 0
		exp_req = calculate_exp_cap()
		levelup()
		#calculate_exp(0)
	else:
		exp += collected_exp
		collected_exp = 0
		
	set_expbar(exp, exp_req)

func calculate_exp_cap():
	var exp_cap = exp_level
	if exp_level < 20:
		exp_cap = exp_level * 5
	elif exp_level < 40:
		exp_cap + 95 * (exp_level - 19) * 8
	else:
		exp_cap = 255 + (exp_level - 39) * 12
	
	return exp_cap

func set_expbar(set_value = 1, set_max_value = 100):
	exp_bar.value = set_value
	exp_bar.max_value = set_max_value
	
func levelup():
	sndLevelUp.play()
	lbl_lvl.text = str("Level: ", exp_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	
	get_tree().paused = true
	
func upgrade_character(upgrade):
	match upgrade:
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			normal_move_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.10
		"scroll1","scroll2","scroll3","scroll4":
			spell_cd += 0.05
		"fireshield1": 
			fireshield_level = 1 
		"fireshield2":
			fireshield_level = 2
		"fireshield3":
			fireshield_level = 3 
		"fireshield4":
			fireshield_level = 4 
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
			
	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_exp(0) 
	#spawn_fireshield(fireshield_level)
	
func get_random_item():
	var dblist = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades: #Already collected
			pass
		elif i in upgrade_options: #Already an option
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item": #Don't pick food
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0: #Check for prerequisites
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				var to_add = true
				if not n in collected_upgrades:
					to_add = false
					if to_add: 
						dblist.append(i)
				else:
					dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var random_item = dblist.pick_random()
		upgrade_options.append(random_item)
		
		return random_item
	else:
		return null

func change_time(argtime = 0):
	time = argtime
	var get_m = int(time/60.0)
	var get_s = time % 60
	
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lblTimer.text = str(get_m, ":", get_s)
		
func adjust_gui_collection(upgrade):
	var get_upgraded_displaynames = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displaynames in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func death():
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	var tween2 = deathPanel.create_tween()
	var tween3 = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50),3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween2.tween_property(collectedWeapons, "position", Vector2(240,140), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween3.tween_property(collectedUpgrades, "position", Vector2(240,160), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	if time >= 300: 
		lblResult.text = "You win"
		sndVictory.play()
	else:
		lblResult.text = "You lose"
		sndLoss.play()
	
func _input(event):
	if event.is_action_pressed("menu"):
		if get_tree().paused == false:
			get_tree().paused = true
			menuPanel.visible = true

func _on_back_btn_pressed():
	menuPanel.visible = false
	get_tree().paused = false

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_main_menu_btnà_pressed():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

func _on_lvl_1_btn_pressed():
	$GUILayer/GUI/LevelChoices.visible = false
	get_tree().paused = false
	$"../MainMusic".play()

func _on_lvl_2_btn_pressed():
	$"../Background".visible = false
	$"../Background2".visible = true
	$GUILayer/GUI/LevelChoices.visible = false
	get_tree().paused = false
	$"../MainMusic2".play()

