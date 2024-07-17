extends Control

@export var area_type: Card.AreaType
@export var index: int = 0

var is_free: bool = true
var current_cards: Array[Card]

func change_card_area(area: Control) -> void:
	current_cards[0].animate_to_area(area)
	
func add_card(card: Card) -> void:
	if card not in current_cards:
		current_cards.append(card)
		is_free = false

func remove_card(card: Card) -> void:
	current_cards.erase(card)
	if current_cards.size() == 0:
		is_free = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	return
	var card: Card = area.owner
	add_card(card)

func _on_area_2d_area_exited(area: Area2D) -> void:
	return
	var card: Card = area.owner 
	remove_card(card)
