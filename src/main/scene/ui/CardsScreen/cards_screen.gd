extends Control

const CARD = preload("res://src/main/scene/ui/Common/Card/card.tscn")
const INVENTORY_AREA = preload("res://src/main/scene/ui/Common/InventoryArea/inventory_area.tscn")
const EQUIPMENT_AREA = preload("res://src/main/scene/ui/Common/EquipmentArea/equipment_area.tscn")

@onready var level_label: Label = $PlayerLevel/LevelLabel
@onready var refresh_button: TextureButton = $VBoxContainer/ShopArea/RefreshButton
@onready var shop_area: Control = $VBoxContainer/ShopArea

@onready var inventorys: HBoxContainer = $VBoxContainer/InventoryPanel/HBoxContainer
@onready var equipments_1: HBoxContainer = $VBoxContainer/EquipmentPanel/HBoxContainer
@onready var equipments_2: HBoxContainer = $VBoxContainer/EquipmentPanel2/HBoxContainer

@onready var stars = [
	$VBoxContainer/StarProbs/Star1,
	$VBoxContainer/StarProbs/Star2,
	$VBoxContainer/StarProbs/Star3,
	$VBoxContainer/StarProbs/Star4,
	$VBoxContainer/StarProbs/Star5
]

@onready var probs = [
	$VBoxContainer/StarProbs/Prob1,
	$VBoxContainer/StarProbs/Prob2,
	$VBoxContainer/StarProbs/Prob3,
	$VBoxContainer/StarProbs/Prob4,
	$VBoxContainer/StarProbs/Prob5
]

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card_spawn_marker_2d: Marker2D = $CardSpawnMarker2D

@onready var end_button = $EndButton

var tween_show: Tween

var my_player: PlayerBase
var draw_amount: int = 5
var inventory_areas: Array
var equipment_areas: Array

var any_following_mouse: bool = false

var inshop_cards: Array[Card]
var outshop_cards: Array[Card]
var reserve_cards: Array[Card] ## 保留卡，当库存满时就会添加到这个数组中，在 _process 中检测到有库存时自动添加到库存中

func _ready() -> void:
	hide()
	my_player = owner
	my_player.player_level_changed.connect(_on_player_level_changed)
	update_star_probs(my_player.player_level)
	
	inventory_areas = inventorys.get_children()
	var e1 = equipments_1.get_children()
	var e2 = equipments_2.get_children()
	equipment_areas = e1 + e2
	
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	
func _process(_delta: float) -> void:
	if my_player.draw_result_queue.size() == draw_amount:
		spawn_cards(my_player.draw_result_queue, draw_amount)
	
	if reserve_cards.size() > 0:
		for card in reserve_cards:
			var free_inventory_area = get_free_inventory_area()
			if free_inventory_area:
				free_inventory_area.is_free = false
				card.animate_to_area(free_inventory_area, 0.5)
				card.animate_scale(false)

				outshop_cards.append(card)
				reserve_cards.erase(card)

func update_star_probs(player_level: int) -> void:
	level_label.text = str(player_level)
	var star_probs = WeaponsManager.map_level_to_star_probs(player_level)

	for i in range(stars.size()):
		if star_probs.has(i + 1):
			stars[i].show()
			probs[i].show()
			probs[i].text = str(star_probs[i + 1])
		else:
			stars[i].hide()
			probs[i].hide()
					
func add_target_card(weapon_id: int) -> Card:
	var weapon_pool_item: Dictionary = WeaponsManager.get_weapon_pool_item(weapon_id)
	var instance: Card = CARD.instantiate()
	instance.global_position = card_spawn_marker_2d.global_position
	instance.card_screen = self
	instance.my_player = my_player
	instance.weapon_id = weapon_pool_item["weapon_id"]
	instance.my_icon_path = weapon_pool_item["icon_path"]
	instance.my_star_rating = weapon_pool_item["star_rating"]
	instance.my_price = weapon_pool_item["price"]
	
	instance.be_purchased.connect(_on_card_be_purchased)
	instance.be_sold.connect(_on_card_be_sold)
		
	add_child(instance)
	
	reserve_cards.append(instance)
	
	return instance

func spawn_cards(result: Array, amount: int) -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	for i in range(amount):
		var weapon_pool_item = result[i]
		var instance: Card = CARD.instantiate()
		instance.global_position = card_spawn_marker_2d.global_position
		instance.card_screen = self
		instance.my_player = my_player
		instance.weapon_id = weapon_pool_item["weapon_id"]
		instance.my_icon_path = weapon_pool_item["icon_path"]
		instance.my_star_rating = weapon_pool_item["star_rating"]
		instance.my_price = weapon_pool_item["price"]
		
		instance.be_purchased.connect(_on_card_be_purchased)
		instance.be_sold.connect(_on_card_be_sold)
		inshop_cards.append(instance)
		
		add_child(instance)

		var final_pos = get_final_pos(i)
		tween.parallel().tween_property(instance, "global_position", final_pos, 0.2*(i+1))

	result.clear()

func destroy_all_inshop_cards() -> void:
	for card in inshop_cards:
		card.to_free()
	inshop_cards.clear()

func request_draw_weapon(amount: int) -> void:
	for i in range(amount):
		WeaponsManager.request_draw_weapon.rpc(Tools.my_id(), my_player.player_level)

func get_final_pos(index: int) -> Vector2:
	var y = shop_area.position.y + shop_area.size.y / 2
	var width = shop_area.size.x / draw_amount
	var x = shop_area.position.x + (index + 0.5) * width
	
	return Vector2(x, y)

func get_free_inventory_area() -> CardArea:
	for area in inventory_areas:
		if area.is_free:
			return area
	return null
	
func merge_check(card: Card) -> bool:
	var count: int = 1
	for _card in outshop_cards:
		if _card.is_equal(card) and _card != card:
			count += 1
	if count >= 3:
		return true
	return false

func get_merge_target(card: Card) -> Card:
	var target_card = card
	var target_area_type = Card.AreaType.INVENTORY
	var target_index = 100
	if card.current_area:
		target_area_type = card.current_area.area_type
		target_index = card.current_area.index
	for _card in outshop_cards:
		if _card.is_equal(card):
			var area_type: Card.AreaType = _card.current_area.area_type
			var index = _card.current_area.index
			if area_type == Card.AreaType.EQUIPMENT:
				if target_area_type == Card.AreaType.INVENTORY:
					target_card = _card
					target_area_type = area_type
					target_index = index
				elif target_area_type == Card.AreaType.EQUIPMENT:
					if index < target_index:
						target_card = _card
						target_area_type = area_type
						target_index = index
			elif area_type == Card.AreaType.INVENTORY:
				if target_area_type == Card.AreaType.INVENTORY:
					if index < target_index:
						target_card = _card
						target_area_type = area_type
						target_index = index

	# print("合成目标：", target_card)
	# print("合成类型：", target_area_type)
	# print("合成索引：", target_index)
	return target_card

func do_merge(merge_target: Card, new_purchased_card: Card=null) -> void:
	var be_merged_cards: Array[Card] = []
	var index: int = 0
	var duration: float = 0.3
	var total_time: float = 0
	for _card in outshop_cards:
		if _card.is_equal(merge_target) and _card != merge_target:
			_card.merged = true
			_card.animate_to_card(merge_target, (index+1) * duration)
			total_time += (index+1) * duration
			be_merged_cards.append(_card)
			index += 1
	if new_purchased_card:
		new_purchased_card.merged = true
		new_purchased_card.animate_to_card(merge_target, (index+1) * duration)
		total_time += (index+1) * duration
		be_merged_cards.append(new_purchased_card)

	for card in be_merged_cards:
		outshop_cards.erase(card)

	await get_tree().create_timer(total_time).timeout
	merge_target.upgrade_weapon_level()

	if merge_check(merge_target):
		var new_merge_target = get_merge_target(merge_target)
		do_merge(new_merge_target)

func show_screen() -> void:
	show()
	animation_player.play("show_screen")
	request_draw_weapon(draw_amount)
	
func hide_screen() -> void:
	animation_player.play_backwards("show_screen")
	await animation_player.animation_finished
	hide()
	destroy_all_inshop_cards()
	
func switch() -> void:
	if animation_player.is_playing():
		return
	if visible: hide_screen()
	else: show_screen()

func _on_player_level_changed(player_level: int) -> void:
	update_star_probs(player_level)
	
func _on_refresh_button_pressed() -> void:
	destroy_all_inshop_cards()
	request_draw_weapon(draw_amount)

func _on_update_level_button_pressed() -> void:
	my_player.player_level += 1

func _on_card_be_sold(card: Card, return_coin: bool) -> void:
	if return_coin:
		my_player.coin_count += card.my_price
	if card in outshop_cards:
		outshop_cards.erase(card)

func _on_card_be_purchased(card: Card, need_coin: bool) -> void:
	if need_coin:
		my_player.coin_count -= card.my_price

	if card in inshop_cards:
		inshop_cards.erase(card)

	if merge_check(card):
		var merge_target = get_merge_target(card)
		do_merge(merge_target, card)
		
	else:
		var free_inventory_area = get_free_inventory_area()
		if free_inventory_area:
			free_inventory_area.is_free = false
			card.animate_to_area(free_inventory_area, 0.5)
			card.animate_scale(false)

			outshop_cards.append(card)

func _on_end_button_pressed():
	hide_screen()

func _on_test_button_pressed() -> void:
	add_target_card(randi_range(0, 20))
