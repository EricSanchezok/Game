extends Node2D

func _ready() -> void:
	pass

func _on_test_timer_1_timeout() -> void:
	pass
	EnemiesManager.register_enemy("Shade", "A", 1, 1.0)

func _on_test_timer_2_timeout() -> void:
	#Game.players[1].register_weapon.emit(1, 20, 0)
	Game.players[1].register_weapon.emit(1, 21, 1)
	Game.players[1].register_weapon.emit(1, 22, 2)
	Game.players[1].register_weapon.emit(1, 23, 3)
	Game.players[1].register_weapon.emit(1, 24, 4)
	Game.players[1].register_weapon.emit(1, 25, 5)
	Game.players[1].register_weapon.emit(1, 26, 6)
	Game.players[1].register_weapon.emit(1, 27, 7)
	
