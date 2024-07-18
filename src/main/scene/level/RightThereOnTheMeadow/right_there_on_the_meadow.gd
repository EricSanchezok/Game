extends Node2D

func _ready() -> void:
	pass

func _on_test_timer_1_timeout() -> void:
	pass
	# EnemiesManager.register_enemy("Shade", "A", 1, 1.0)

func _on_test_timer_2_timeout() -> void:
	for player_id in Game.players.keys():
		print(Game.players[player_id])
