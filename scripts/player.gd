extends CharacterBody2D

@export_group("Stats")
@export var speed = 300.0
@export var max_health: float = 100.0
@export var xp_to_level: float = 10.0

@onready var camera: Camera2D = $Camera2D

signal health_changed(new_val, max_val)
signal xp_changed(new_val, max_val)

var current_health: float = 100.0
var current_xp: float = 0.0
var current_level: int = 1

func _physics_process(_delta):
	# On récupère les directions (touches fléchées, ZQSD ou Joystick mobile)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# On applique le mouvement
	velocity = direction * speed
	move_and_slide()

func camera_shake(intensity: float, time: float):
	var tween = create_tween()
	for i in range(10):
		var target_pos = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", target_pos, time/10.0)
	
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func take_damage(amount: float):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health) # Évite de descendre sous 0
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	print("Game Over")
	# Pour l'instant on reload juste la scène
	get_tree().reload_current_scene()
