extends Area2D

var xp_value: int = 150
var speed: float = 0.0
var target: Node2D = null
var collecting: bool = false

func _process(delta):
	if collecting and target:
		# La gemme accélère vers le joueur
		speed += 15.0
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
		
		# Si elle touche presque le joueur, on la consomme
		if global_position.distance_to(target.global_position) < 10.0:
			target.add_xp(xp_value)
			queue_free()

func collect(player_node):
	target = player_node
	collecting = true
