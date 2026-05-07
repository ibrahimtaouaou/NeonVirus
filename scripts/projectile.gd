extends Area2D

@onready var sprite = $Sprite2D
@onready var despawn_timer: Timer = $DespawnTimer

var velocity = Vector2.ZERO
var damage = 5.0
var is_active: bool = false

func _physics_process(delta):
	position += velocity * delta

func _on_area_entered(area):
	if not is_active:
		return
	
	# Only hit things that are actually active/visible in the world
	if not area.is_visible_in_tree():
		return
		
	if area.has_method("take_damage"):
		#print("Projectile hit: ", area.name, " (Parent: ", area.get_parent().name if area.get_parent() else "None", ")")
		is_active = false
		area.take_damage(damage)
		ProjectileManager._return_to_pool(self)
	#else:
		#print("Projectile overlapped with non-damageable: ", area.name)

func setup(data: ProjectileData, pos: Vector2, dir: Vector2):
	# 1. On active le projectile
	is_active = true
	global_position = pos
	show()
	set_physics_process(true)
	monitoring = true
	monitorable = true
	
	# 2. On applique les stats de la ressource
	damage = data.damage
	velocity = dir * data.speed
	rotation = dir.angle()
	
	# 3. On applique le visuel de la ressource
	if sprite and data.texture:
		sprite.texture = data.texture
		sprite.modulate = data.color
		sprite.scale = data.scale
	
	# 4. Timer restart
	despawn_timer.start()
	show()


func _on_despawn_timer_timeout() -> void:
	if is_active:
		is_active = false
		ProjectileManager._return_to_pool(self)
