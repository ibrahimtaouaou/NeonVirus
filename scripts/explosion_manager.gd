extends Node2D

var explosion_pool = []
@onready var template = $ExplosionTemplate

func _ready():
	# On commence avec 15, c'est une bonne base
	for i in range(15):
		_add_new_explosion_to_pool()
	template.hide()

func _add_new_explosion_to_pool():
	var new_exp = template.duplicate()
	add_child(new_exp)
	explosion_pool.append(new_exp)
	return new_exp

func spawn_explosion(target_position: Vector2):
	# 1. On cherche une explosion libre
	for explo in explosion_pool:
		if not explo.emitting:
			_activate_explosion(explo, target_position)
			return

	# 2. SI ON ARRIVE ICI, c'est que le pool est vide (trop d'ennemis !)
	# On en crée une nouvelle à la volée pour dépanner
	print("Pool vide, extension du pool !")
	var extra_exp = _add_new_explosion_to_pool()
	_activate_explosion(extra_exp, target_position)

func _activate_explosion(explo, pos):
	explo.global_position = pos
	explo.emitting = true
	explo.restart()
