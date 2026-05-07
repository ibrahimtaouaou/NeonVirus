extends Node

signal player_spawned(player)

func emit_player_spawned(player_node):
	player_spawned.emit(player_node)
