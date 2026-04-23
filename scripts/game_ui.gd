extends CanvasLayer

@onready var health_bar = $HUD/HPBar
@onready var xp_bar = $HUD/XPBar
@onready var level_label = $HUD/LevelLabel

func _ready():
	# On trouve le joueur pour écouter ses signaux
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_updated)
		player.xp_changed.connect(_on_xp_updated)
		
		# Initialisation des barres
		_on_health_updated(player.current_health, player.max_health)
		_on_xp_updated(player.current_xp, player.xp_to_level)

func _on_health_updated(val, max_val):
	health_bar.max_value = max_val
	health_bar.value = val

func _on_xp_updated(val, max_val):
	xp_bar.max_value = max_val
	xp_bar.value = val
