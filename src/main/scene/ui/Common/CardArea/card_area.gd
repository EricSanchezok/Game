class_name CardArea
extends Control

@export var index: int = 0
var area_type: Card.AreaType

var is_free: bool = true
var current_cards: Array[Card]

func _ready() -> void:
	pass

func change_card_area(area: CardArea) -> void:
	current_cards[0].animate_to_area(area)
	
func add_card(card: Card) -> void:
	if card not in current_cards:
		current_cards.append(card)
		is_free = false

func remove_card(card: Card) -> void:
	current_cards.erase(card)
	if current_cards.size() == 0:
		is_free = true
