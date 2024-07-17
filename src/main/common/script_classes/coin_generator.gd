class_name CoinGenerator
extends Node

const COIN = preload("res://src/main/scene/other/Coin/coin.tscn")

func generate_coins(value: int = 1, count: int = 1) -> void:
	for i in range(count):
		var coin = COIN.instantiate()
		coin.global_position = owner.global_position
		coin.target_point = owner.global_position + Vector2(randf_range(-25, 25), randf_range(0, 15))
		coin.control_height = randf_range(50, 70)
		coin.total_time = randf_range(0.2, 0.5)
		coin.value = value
		coin.type = "Coin"
		
		Game.add_object(coin)
		
func generate_energy(value: float) -> void:
	var coin = COIN.instantiate()
	coin.global_position = owner.global_position
	coin.target_point = owner.global_position + Vector2(randf_range(-25, 25), randf_range(0, 15))
	coin.control_height = randf_range(50, 70)
	coin.total_time = randf_range(0.2, 0.5)
	coin.value = value
	coin.type = "Energy"
	
	Game.add_object(coin)


