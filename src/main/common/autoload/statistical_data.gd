extends Node


var weapon_kill_data = {}
var weapon_damage_data = {}

func _ready() -> void:
	Game.start_game.connect(_on_start_game)
	
func _on_start_game(level: Node2D) -> void:
	for player_id in Game.players.keys():
		weapon_damage_data[player_id] = {}
		weapon_kill_data[player_id] = {}

func register_damage(player_id: int, weapon_id: int, damage_amount: float) -> void:
	if not weapon_damage_data[player_id].has(weapon_id):
		weapon_damage_data[player_id][weapon_id] = 0.0
	weapon_damage_data[player_id][weapon_id] += damage_amount
	
func register_kill(player_id: int, weapon_id: int) -> void:
	if not weapon_kill_data[player_id].has(weapon_id):
		weapon_kill_data[player_id][weapon_id] = 0
	weapon_kill_data[player_id][weapon_id] += 1
