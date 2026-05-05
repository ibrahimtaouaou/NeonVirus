extends Node

@export var projectile_scene: PackedScene = preload("res://scenes/projectile.tscn")
var pool_size = 100
var pool = []

func _ready():
	# On attend un peu que la scène soit prête pour trouver le World
	call_deferred("_init_pool")

func _init_pool():
	var world = get_tree().root.find_child("World", true, false)
	var parent = world if world else self
	
	for i in range(pool_size):
		var p = projectile_scene.instantiate()
		parent.add_child(p)
		pool.append(p)
		_return_to_pool(p)

func spawn_projectile(data: ProjectileData, pos: Vector2, dir: Vector2):
	var p = _get_from_pool()
	if p:
		p.setup(data, pos, dir)
	else:
		var active_count = 0
		for proj in pool:
			if proj.is_active: active_count += 1
		print("DEBUG POOL: Total=", pool.size(), " Active=", active_count)
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
