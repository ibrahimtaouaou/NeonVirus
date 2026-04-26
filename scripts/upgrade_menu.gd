extends CanvasLayer

@export var card_scene: PackedScene = preload("res://scenes/upgrade_card.tscn")

@onready var options_container: HBoxContainer = $CenterContainer/VBoxContainer/HBoxContainer

var upg_speed = preload("res://resources/upg_speed.tres")
var upg_health = preload("res://resources/upg_health.tres")
var player

func open_menu(upgrade_options: Array):
	# 1. On met le jeu en pause
	get_tree().paused = true
	show()
	
	# 2. On nettoie les anciens boutons
	for child in options_container.get_children():
		child.queue_free()
	
	# 3. On crée les nouveaux boutons pour chaque option
	for upgrade in upgrade_options:
		var card = card_scene.instantiate()
		options_container.add_child(card)
		card.setup(upgrade)
		card.selected.connect(_on_card_selected)
	
	# 4. On remplit le texte
		player = get_tree().get_first_node_in_group("player")
		if player.levels_pending > 0:
			var upgrade_orth = "upgrade" if player.levels_pending == 1 else "upgrades"
			$CenterContainer/VBoxContainer/UpgradesLeftLabel.text = str(player.levels_pending)+ " more " + upgrade_orth

func prepare_new_upgrade_options():
	var all_upgrades = [upg_speed, upg_health]
	all_upgrades.shuffle()
	open_menu(all_upgrades.slice(0, 3))

func _on_card_selected(data):
	#var player = get_tree().get_first_node_in_group("player")
	player.apply_upgrade(data)
	player.levels_pending -= 1
	
	if player.levels_pending > 0:
		# On relance avec de nouvelles options
		prepare_new_upgrade_options() 
	else:
		hide()
		get_tree().paused = false
