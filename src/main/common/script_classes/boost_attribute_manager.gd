class_name BoostAttributeManager
extends Node

var my_player: PlayerBase
var current_boosts: Array = []

signal register_boost(boost_data: Dictionary)

func _ready() -> void:
	my_player = owner
	register_boost.connect(_on_register_boost)
	
func check_boost(type: String, id: int) -> bool:
	for boost in current_boosts:
		if boost["type"] == type and boost["id"] == id:
			return true
	return false
	
func _on_register_boost(boost_data) -> void:
	current_boosts.append(boost_data)
