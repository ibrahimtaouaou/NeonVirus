extends CanvasLayer

@onready var health_bar = $HUD/HPBar
@onready var xp_bar = $HUD/XPBar
@onready var level_label = $HUD/LevelLabel
@onready var level_up_notice: Label = $HUD/LevelUpNotice
@onready var upgrade_menu: CanvasLayer = $"../UpgradeMenu"

func _ready():
	# On trouve le joueur pour écouter ses signaux
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_updated)
		player.xp_changed.connect(_on_xp_updated)
		player.leveled_up.connect(_on_level_up)
		
		# Initialisation des barres
		_on_health_updated(player.current_health, player.max_health)
		_on_xp_updated(player.current_xp, player.xp_to_level)
		level_label.text = "Level : %s"  %player.current_level

func _on_health_updated(val, max_val):
	health_bar.max_value = max_val
	health_bar.value = val

func _on_xp_updated(current_val, max_val):
	xp_bar.max_value = max_val
	var tween = create_tween()
	tween.tween_property(xp_bar, "value", current_val, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	xp_bar.value = current_val

func _on_level_up(new_level):
	level_label.text = "LVL : " + str(new_level)
	var tween = create_tween().set_parallel(true)
	# --- EFFET A : Le Flash de la barre d'XP ---
	# On fait devenir la barre blanche/brillante puis elle revient à sa couleur normale
	xp_bar.modulate = Color(3, 3, 3) # "Overbright" pour un effet de bloom/flash
	tween.tween_property(xp_bar, "modulate", Color.WHITE, 0.5)
	
	# --- EFFET B : Le Texte "LEVEL UP !" ---
	level_up_notice.scale = Vector2.ZERO
	level_up_notice.modulate.a = 1.0 # On le rend visible
	level_up_notice.position.y = 300 # Position de départ
	
	# Animation du texte : il grossit et monte
	tween.tween_property(level_up_notice, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(level_up_notice, "position:y", 250, 0.6)
	
	# --- EFFET C : Disparition en fondu ---
	# On crée un deuxième tween (non-parallèle) pour la sortie
	var fade_tween = create_tween()
	fade_tween.tween_interval(0.8) # On attend un peu que le joueur lise
	fade_tween.tween_property(level_up_notice, "modulate:a", 0.0, 0.3)
	
	upgrade_menu.show()
	upgrade_menu.prepare_new_upgrade_options()
