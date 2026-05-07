extends Node2D

@export var current_projectile_data: ProjectileData
@export var range_radius: float = 400.0 # Rayon assez généreux

func _on_timer_timeout():
	var target = find_closest_enemy()
	if target:
		shoot(target)

func find_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_enemy = null
	var shortest_distance = range_radius
	
	for enemy in enemies:
		# Use is_visible_in_tree() to be sure the enemy is active
 		# and not just hidden via deferred call
		if not enemy.is_visible_in_tree(): continue
		# Ensure it's a valid target that can take damage
		if not enemy.has_method("take_damage"): continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			closest_enemy = enemy
	return closest_enemy

func shoot(target):
	var direction = (target.global_position - global_position).normalized()
	ProjectileManager.spawn_projectile(current_projectile_data, global_position, direction)
