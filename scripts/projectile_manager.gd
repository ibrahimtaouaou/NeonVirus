extends Node

@export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
var pool_size = 200
var pool = []

func _ready():
	# On attend un peu que la scène soit prête pour trouver le World
	call_deferred("_first_time_init")
	get_tree().node_added.connect(_on_node_added)

func _first_time_init():
	for i in range(pool_size):
		var p = projectile_scene.instantiate()
		add_child(p)
		pool.append(p)
		_return_to_pool(p)

func _new_game_reset():
	for p in pool:
		if p.is_active:
			_return_to_pool(p)

func _on_node_added(node):
	if node.name == "Main":
		# On attend une frame pour être sûr que tout est prêt
		call_deferred("_new_game_reset")

func spawn_projectile(data: ProjectileData, pos: Vector2, dir: Vector2):
	var p = _get_from_pool()
	if p:
		p.setup(data, pos, dir)
	else:
		print("Pool empty or no projectile found!")

func _get_from_pool():
	for p in pool:
		if not p.is_active:
			return p
	return null

func _return_to_pool(p):
	p.is_active = false
	p.set_deferred("visible", false)
	p.set_physics_process(false)
	p.set_process(false)
	p.set_deferred("monitoring", false)
	p.set_deferred("monitorable", false)
	p.despawn_timer.stop()
