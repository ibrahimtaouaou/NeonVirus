extends Node2D

@export var enemy_templates: Array[PackedScene] # BaseEnemy, FastEnemy, TankEnemy ici
@export var pool_size: int = 100     # Nombre d'ennemis créés au départ
@export var spawn_radius: float = 1500.0 # Distance de spawn (hors écran)

var enemy_pool: Array = []

func _ready():
	# 1. On pré-remplit le pool
	for i in range(pool_size):
		var random_scene = enemy_templates.pick_random() # Choisit au pif
		var enemy = random_scene.instantiate()
		enemy.hide() # On le cache
		enemy.set_process(false) # On stoppe son script
		add_child(enemy)
		enemy_pool.append(enemy)

func _on_spawn_timer_timeout():
	spawn_enemy()

func spawn_enemy():
	# 2. On cherche un ennemi disponible dans le pool
	var enemy = get_available_enemy()
	if enemy:
		# 3. Calcul de la position de spawn en cercle autour du joueur
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var random_angle = randf() * TAU
			var spawn_pos = player.global_position + Vector2.RIGHT.rotated(random_angle) * spawn_radius
			
			# 4. On réactive l'ennemi
			enemy.global_position = spawn_pos
			enemy.show()
			enemy.set_process(true)
			# On réactive sa collision si elle était coupée
			enemy.get_node("MainCollision").disabled = false 
			enemy.get_node("Trail").emitting = true 

func get_available_enemy():
	for e in enemy_pool:
		if not e.visible: # Si l'ennemi est caché, il est libre
			return e
	return null # Pool vide (tous les ennemis sont à l'écran)
