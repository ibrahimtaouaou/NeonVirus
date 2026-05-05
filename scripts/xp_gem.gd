extends Area2D

var xp_value: int = 1
var speed: float = 0.0
var target: Node2D = null
var collecting: bool = false # Player next to gem
var is_active: bool = false # For pooling in GemManager
var player: Node2D # On stocke le joueur ici une fois dans le Manager

func _process(delta):
	if not is_active : return

	if collecting and target:
		# Gem accelerate towards the player
		speed += 15.0
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
		
		# If it too close to player, it disappears
		if global_position.distance_to(target.global_position) < 10.0:
			target.add_xp(xp_value)
			despawn()
	else:
		# Si la gemme est au sol, on vérifie si le joueur entre dans le rayon
		_check_for_player()

func collect(player_node):
	target = player_node
	collecting = true

func spawn(pos: Vector2, value: int, player_ref: Node2D):
	global_position = pos
	xp_value = value
	collecting = false
	target = null
	speed = 0.0
	player = player_ref
	is_active = true
	$CollisionShape2D.set_deferred("disabled", false)
	show()
	_check_for_player()

func despawn():
	is_active = false
	hide()
	$CollisionShape2D.set_deferred("disabled", true)

func _check_for_player():
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist <= player.grab_radius:
			collect(player)
