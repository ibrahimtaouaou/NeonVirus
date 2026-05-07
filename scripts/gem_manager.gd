extends Node

var gem_scene = preload("res://scenes/xp_gem.tscn")
var pool_size = 300
var pool = []
var player_ref: Node2D

func _ready():
	_first_time_init()
	get_tree().node_added.connect(_on_node_added)

func _new_game_reset():
	call_deferred("_find_new_player")
	for gem in pool:
		gem.despawn()
	print("Manager réinitialisé pour la nouvelle scène")

func _first_time_init():
	_find_new_player()
	for i in range(pool_size):
		var gem = gem_scene.instantiate()
		add_child(gem) # Enfant du manager : survit au reload_scene
		gem.hide()
		gem.is_active = false
		pool.append(gem)

func _on_node_added(node):
	# Si le nœud qui vient d'être ajouté s'appelle "World"
	# (ou le nom de ta scène principale)
	if node.name == "Main":
		# On attend une frame pour être sûr que tout est prêt
		call_deferred("_new_game_reset")


func spawn_gem(pos: Vector2, value: int):
	if not is_instance_valid(player_ref):
		player_ref = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player_ref):
			return
			
	# --- ÉTAPE 1 : LA FUSION (Stratégie 2) ---
	# On cherche si une gemme est déjà au sol tout près (ex: 40 pixels)
	# pour lui ajouter la valeur plutôt que d'en créer une nouvelle.
	for g in pool:
		if g.is_active and not g.collecting:
			if g.global_position.distance_to(pos) < 200.0:
				g.xp_value += value
				# Petit effet visuel pour montrer que la gemme grossit
				g.scale = clamp(g.scale + Vector2(0.1, 0.1), Vector2(1, 1), Vector2(2.5, 2.5))
				return

	# --- ÉTAPE 2 : LE POOL CLASSIQUE ---
	# Si pas de fusion possible, on cherche une gemme libre
	for g in pool:
		if not g.is_active:
			#g.scale = Vector2(1, 1) # Reset la taille
			g.spawn(pos, value, player_ref)
			return

	# --- ÉTAPE 3 : LE RECYCLAGE (Stratégie 1) ---
	# Si le pool est plein ET aucune fusion trouvée, on recycle la plus loin
	var farthest_gem = _get_farthest_gem()
	if farthest_gem:
		# On récupère l'XP de la gemme sacrifiée pour ne pas la perdre !
		var old_xp = farthest_gem.xp_value
		farthest_gem.spawn(pos, value + old_xp, player_ref)
		#farthest_gem.scale = Vector2(1, 1)

func _get_farthest_gem():
	var target_gem = null
	var max_dist = -1.0
	for g in pool:
		# On ne recycle que ce qui n'est pas déjà en mouvement vers le joueur
		if g.is_active and not g.collecting:
			var d = g.global_position.distance_to(player_ref.global_position)
			if d > max_dist:
				max_dist = d
				target_gem = g
	return target_gem

#func clear_all_gems():
	#for gem in pool:
		#if gem.is_active:
			#gem.despawn() # On utilise ta fonction qui cache et désactive la gemme

func _find_new_player():
	player_ref = get_tree().get_first_node_in_group("player")
