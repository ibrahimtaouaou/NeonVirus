extends Area2D

var xp_value: int = 1
var speed: float = 0.0
#var target: Node2D = null
var collecting: bool = false # Player next to gem
var is_active: bool = false # For pooling in GemManager
var player: Node2D # On stocke le joueur ici une fois dans le Manager
var active_tween: Tween

func _ready() -> void:
	add_to_group("gems")

func collect(player_node):
	collecting = true
	# Disable collision immediately so it's only collected once
	$CollisionShape2D.set_deferred("disabled", true)
	
	if active_tween:
		active_tween.kill()

	active_tween = create_tween()
	
	# Move to player's position over 0.4 seconds
	# .set_trans(TWween.TRANS_BACK) makes it pop or fly smoothly
	active_tween.tween_property(self, "global_position", player_node.global_position, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	active_tween.tween_callback(_on_collect_finished.bind(player_node))
	
func _on_collect_finished(player_node):
	if is_instance_valid(player_node):
		player_node.add_xp(xp_value)
	despawn()


func spawn(pos: Vector2, value: int, player_ref: Node2D):
	global_position = pos
	xp_value = value
	collecting = false
	#target = null
	speed = 0.0
	player = player_ref
	is_active = true
	$CollisionShape2D.set_deferred("disabled", false)
	scale = Vector2(1, 1) #  Set normal size
	show()
	if player and global_position.distance_to(player.global_position) < player.grab_radius:
		collect(player)

func despawn():
	is_active = false
	collecting = false
	if active_tween:
		active_tween.kill()
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
