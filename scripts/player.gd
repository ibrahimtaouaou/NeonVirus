extends CharacterBody2D

@export_group("Stats")
@export var speed = 300.0
@export var max_health: float = 100.0
@export var xp_to_level: float = 10.0
@export var grab_radius: float = 250.0

@onready var camera: Camera2D = $Camera2D
#@onready var level_label: Label = $"../../GameUI/HUD/LevelLabel"

signal health_changed(new_val, max_val)
signal xp_changed(new_val, max_val)
signal leveled_up(new_level)

var current_health: float = 100.0
var current_xp: float = 0.0
var current_level: int = 1
var levels_pending: int = 0
var is_dead: bool = false

func _ready() -> void:
	GameEvents.emit_player_spawned(self)

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

func _on_grab_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("gems") and area.is_active and not is_dead:
		area.collect(self)

func player_take_damage(amount: float):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health) # Évite de descendre sous 0
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func die():
	if is_dead: return
	is_dead = true
	print("Game Over")
	get_tree().call_deferred("reload_current_scene")

func add_xp(amount):
	current_xp += amount
	while current_xp >= xp_to_level:
		current_xp -= xp_to_level
		levels_pending += 1
		level_up()
	xp_changed.emit(current_xp, xp_to_level)

func level_up():
	current_level += 1
	leveled_up.emit(current_level)
	xp_to_level *= 1.2 # Le niveau suivant est 20% plus dur
	#level_label.text = "Level : %s"  %current_level
	print("LEVEL UP ! Niveau : ", current_level)

func apply_upgrade(upgrade: UpgradeData):
	match upgrade.type:
		"speed":
			print("add speed")
			speed *= upgrade.value # Augmente la vitesse de 20% si valeur = 1.2
		"health":
			print("add health")
			max_health += upgrade.value
			current_health += upgrade.value # Soigne en même temps
			health_changed.emit(current_health, max_health)
		#"damage":
			#attack_damage += upgrade.value
