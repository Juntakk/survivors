extends ColorRect

@onready var lblname = $lbl_name
@onready var lbldesc = $lbl_desc
@onready var lblLvl = $lbl_lvl
@onready var itemIcon = $ColorRect/ItemIcon

var mouse_over = false
var item = null
@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	
	if item == null: 
		item = "food"
		
	lblname.text = UpgradeDb.UPGRADES[item]["displayname"]
	lbldesc.text = UpgradeDb.UPGRADES[item]["details"]
	lblLvl.text = UpgradeDb.UPGRADES[item]["level"]
	itemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])

func _input(event):
	if event.is_action("click"):
		if mouse_over:
			emit_signal("selected_upgrade", item)


func _on_mouse_entered():
	mouse_over = true


func _on_mouse_exited():
	mouse_over = false
