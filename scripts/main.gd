extends Node2D

@onready var grid_material = $Background/GridShader.material 
@onready var camera = $World/Player/Camera2D

func _process(_delta):
	if grid_material and camera:
		# On récupère la position globale de la caméra
		var cam_pos = camera.get_screen_center_position()
		
		# On l'envoie au shader
		# Attention : on inverse souvent la valeur pour que le sol "recule" quand on avance
		grid_material.set_shader_parameter("camera_offset", cam_pos * 0.5)
