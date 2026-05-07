extends Area2D 
class_name BaseEnemy


@export_group("Stats")
@export var speed: float = 150.0
@export var health: int = 10
@export var contact_damage: int = 1
@export var xp_value: int = 1
@export_group("Visuals")
@export var enemy_color: Color = Color(1, 0, 0) # Rouge par défaut


var player: Node2D = null
var separation_distance: float = 40.0 # Distance à laquelle ils se poussent
var current_health: int = 10

func _process(delta: float):
	if not is_instance_valid(player): 
		player = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(player): 
			return
	
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

func _ready() -> void:
	add_to_group("enemy")
	# On remet les particules "dans" l'ennemi pour le prochain coup
	$ExplosionParticles.set_as_top_level(false) 
	$ExplosionParticles.position = Vector2.ZERO # On les recentre
	$ExplosionParticles.emitting = false
	$Trail.emitting = true
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func set_player(player_ref):
	player = player_ref

func _on_screen_notifier_screen_exited():
	# Recyclage : on cache et on stoppe tout
	set_deferred("visible", false)
	set_process(false)
	set_physics_process(false)
	$MainCollision.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		explode(true)

func explode(collision: bool):
	if not is_visible_in_tree(): return 

	# --- TRAIL ---
	if has_node("Trail"):
		# On arrête de créer de nouvelles particules
		$Trail.emitting = false 
	
	# --- EXPLOSION ---
	Explosions.spawn_explosion(global_position)
	
	# --- DAMAGE ---
	if collision and player:
		player.player_take_damage(10)
	
	# --- DROP ---
	GemManager.spawn_gem(global_position, xp_value)

	# --- DISPARITION ---
	set_deferred("visible", false)
	$MainCollision.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	set_process(false)
	set_physics_process(false)

	# --- SHAKE ---
	if player:
		player.camera_shake(8.0, 0.15)


func reset_enemy():
	# 1. Reset des statistiques
	current_health = health
	
	# 2. Reset de la physique
	set_process(true)
	set_physics_process(true)
	
	# 3. Reset des collisions
	$MainCollision.set_deferred("disabled", false)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
	# 4. Reset visuel
	modulate = Color.WHITE 
	set_deferred("visible", true)
	
	# 5. Relancer les effets (ex: particules de traînée)
	if has_node("Trail"):
		$Trail.emitting = true

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		explode(false)
