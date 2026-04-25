extends Area2D 
class_name BaseEnemy

@export_group("Stats")
@export var speed: float = 150.0
@export var health: int = 10
@export var contact_damage: int = 1
@export_group("Visuals")
@export var enemy_color: Color = Color(1, 0, 0) # Rouge par défaut

@export var gem_scene: PackedScene = preload("res://scenes/xp_gem.tscn")

var player: Node2D = null
var separation_distance: float = 40.0 # Distance à laquelle ils se poussent

func _process(delta: float):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null: return
	
	var dist_to_player = global_position.distance_to(player.global_position)
	var dir_to_player = (player.global_position - global_position).normalized()
	
	# 1. MOUVEMENT
	global_position += dir_to_player * speed * delta

	# 2. ROTATION STABLE
	# On ne change la rotation QUE si on est à une distance raisonnable.
	# Si on est trop près (moins de 15px), on garde la rotation actuelle pour éviter le spasme.
	if dist_to_player > 15.0:
		# On utilise un lerp plus doux pour que ce soit fluide
		var target_angle = dir_to_player.angle()
		rotation = lerp_angle(rotation, target_angle, 0.2)

	# 3. EXPLOSION SÉCURITÉ
	if dist_to_player < 10.0:
		explode()
		#pass

func _ready() -> void:
	# On remet les particules "dans" l'ennemi pour le prochain coup
	$ExplosionParticles.set_as_top_level(false) 
	$ExplosionParticles.position = Vector2.ZERO # On les recentre
	$ExplosionParticles.emitting = false
	$Trail.emitting = true

func _on_screen_notifier_screen_exited():
	# Recyclage : on cache et on stoppe tout
	hide()
	set_process(false)
	$MainCollision.set_deferred("disabled", true)

func explode():
	if not is_visible_in_tree(): return 

	# --- TRAIL ---
	if has_node("Trail"):
		# On arrête de créer de nouvelles particules
		$Trail.emitting = false 
	
	# --- EXPLOSION ---
	Explosions.spawn_explosion(global_position)
	
	# --- DAMAGE ---
	if player and player.has_method("take_damage"):
		player.take_damage(10.0)
	
	# --- DROP ---
	var gem = gem_scene.instantiate()
	gem.global_position = global_position
	get_parent().add_child(gem)
	
	# --- DISPARITION ---
	hide()
	$MainCollision.set_deferred("disabled", true)
	set_process(false)

	# --- SHAKE ---
	if player:
		player.camera_shake(8.0, 0.15)


func _on_area_entered(area: Area2D) -> void:
	# On vérifie si ce qu'on touche est le joueur
	if area.is_in_group("player"):
		#explode()
		pass
