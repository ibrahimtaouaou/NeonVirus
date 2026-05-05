extends Node

var gem_scene = preload("res://scenes/xp_gem.tscn")
var pool_size = 300
var pool = []
var player_ref: Node2D

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	
	for i in range(pool_size):
		var gem = gem_scene.instantiate()
		gem.hide()
		gem.is_active = false
		add_child(gem)
		pool.append(gem)

func spawn_gem(pos: Vector2, value: int):
	for gem in pool:
		if not gem.is_active:
			gem.spawn(pos, value, player_ref)
			return # On a trouvé une gemme, on s'arrête là
	
	# OPTIONNEL : Si le pool est vide, on peut soit ignorer, 
	# soit prendre la gemme la plus loin du joueur pour la téléporter.
	# print("Plus de gemmes disponibles dans le pool !")
