class_name Card
extends Button

const TRAIT_TEXTURE = preload("res://src/main/scene/ui/Common/TraitTexture/trait_texture.tscn")

@onready var trait_hbox: HBoxContainer = $CardTexture/TraitHbox
@onready var weapon_icon: TextureRect = $CardTexture/WeaponIcon
@onready var price: Label = $CardTexture/Price
@onready var card_texture: TextureRect = $CardTexture
@onready var card_detail: Panel = $CardDetail
@onready var show_detail_timer: Timer = $ShowDetailTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# 生成时传递的参数
var my_player: PlayerBase
var weapon_id: int
var my_traits: Array
var my_icon_path: String
var my_price: int
var my_star_rating: int

signal be_purchased(card: Card)
signal be_sold(card: Card)

var my_level: int = 1
var total_level: int = 1
var purchased: bool = false
var merged: bool = false
		
var card_screen: Control
var current_area: CardArea
var target_areas: Array[CardArea]

var following_mouse: bool = false:
	set(v):
		following_mouse = v
		card_screen.any_following_mouse = v
		
var can_move: bool = true
var tween_scale: Tween
var tween_move: Tween

enum AreaType{
	NONE,
	INVENTORY,
	EQUIPMENT,
	SHOP,
}

func _ready() -> void:
	my_traits = WeaponsManager.get_traits(weapon_id)
	card_texture.texture = card_texture.texture.duplicate()

	for _trait in my_traits:
		var trait_texture = TRAIT_TEXTURE.instantiate()
		trait_texture.my_trait = _trait
		trait_hbox.add_child(trait_texture)

	weapon_icon.texture = load(my_icon_path)

	price.text = str(my_price)
	var rect2 = Rect2(64*(my_star_rating-1), 64, 64, 64)
	card_texture.texture.region = rect2
	
func _process(_delta: float) -> void:
	if no_tween_running() and purchased and not following_mouse and current_area:
		var target_position = get_area_position(current_area)
		global_position = target_position
	if following_mouse:
		var mouse_pos: Vector2 = get_global_mouse_position()
		global_position = mouse_pos
	else:
		if card_screen.any_following_mouse:
			mouse_filter = MOUSE_FILTER_IGNORE
		else:
			mouse_filter = MOUSE_FILTER_STOP

func no_tween_running() -> bool:
	if not tween_scale and not tween_move:
		return true
	if tween_scale and not tween_scale.is_running():
		if tween_move and not tween_move.is_running():
			return true
	return false
	
func animate_scale(is_expand: bool) -> void:
	if tween_scale and tween_scale.is_running():
		tween_scale.kill()
	
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	if is_expand:
		tween_scale.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	else:
		tween_scale.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func animate_to_area(area: CardArea, time: float = 0.2) -> void:
	area.add_card(self)

	var target_position = get_area_position(area)

	if tween_move and tween_move.is_running():
		tween_move.kill()
	
	can_move = false
	
	tween_move = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_move.tween_property(self, "global_position", target_position, time)
	
	await tween_move.finished
	
	can_move = true
	
	if current_area:
		match current_area.area_type:
			AreaType.INVENTORY:
				pass
			AreaType.EQUIPMENT:
				my_player.unregister_weapon.emit(my_player.multiplayer_id, current_area.index)
	
	match area.area_type:
		AreaType.INVENTORY:
			pass
		AreaType.EQUIPMENT:
			my_player.register_weapon.emit(my_player.multiplayer_id, weapon_id, area.index)
			
	
	if current_area:
		current_area.remove_card(self)
	current_area = area

func animate_to_card(target_card: Card, time: float = 0.2) -> void:
	var target_position = target_card.global_position
	if tween_move and tween_move.is_running():
		tween_move.kill()
	
	can_move = false
	
	tween_move = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween_move.parallel().tween_property(self, "global_position", target_position, time)
	tween_move.parallel().tween_property(self, "scale", Vector2(0.5, 0.5), time)

	await tween_move.finished

	to_free()
	target_card.absorb_card(self)

func animate_absorb(_total_level: int) -> void:
	if tween_scale and tween_scale.is_running():
		tween_scale.kill()
	
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_scale.tween_property(self, "scale", Vector2(1.0 + _total_level*0.1, 1.0 + _total_level*0.1), 0.1)

	await tween_scale.finished

	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_scale.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)

func absorb_card(card: Card) -> void:
	total_level += card.total_level
	my_price += card.my_price
	price.text = str(my_price)
	animate_absorb(total_level)
	if total_level == 3:
		upgrade_weapon_level()
	elif total_level == 9:
		upgrade_weapon_level()

func upgrade_weapon_level() -> void:
	my_level += 1

func get_area_position(area: CardArea) -> Vector2:
	if area.area_type == AreaType.EQUIPMENT and area.index >= 5:
		return area.global_position - area.size/2
	else:
		return area.global_position + area.size/2
	
func handle_area(area: CardArea) -> void:
	match area.area_type:
		AreaType.INVENTORY:
			if not area.is_free:
				area.change_card_area(current_area)
			animate_to_area(area)
		AreaType.EQUIPMENT:
			if not area.is_free:
				area.change_card_area(current_area)
			animate_to_area(area)
		AreaType.SHOP:
			is_sold()

func is_sold() -> void:
	be_sold.emit(self)
	hide_detail()
	to_free()
	
func is_purchased() -> void:
	purchased = true
	hide_detail()

func is_equal(card: Card) -> bool:
	return weapon_id == card.weapon_id and my_level == card.my_level
	
func to_free() -> void:
	WeaponsManager.weapon_pool_change(weapon_id, (my_level-1)*3)
	if current_area:
		current_area.remove_card(self)
	queue_free()
	
func show_detail() -> void:
	animation_player.play("show_detail")
	if not purchased:
		card_detail.position = Vector2(-24, 36)
	else:
		card_detail.position = Vector2(-24, -140)
		
func hide_detail() -> void:
	card_detail.hide()

func _on_mouse_entered() -> void:
	animate_scale(true)
	show_detail_timer.start()
	
func _on_mouse_exited() -> void:
	if not following_mouse:
		animate_scale(false)
	show_detail_timer.stop()
	hide_detail()

func _on_gui_input(event: InputEvent) -> void:
	if not purchased or not can_move: return
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed(): # 按下鼠标时
		z_index = 100
		following_mouse = true
		
	else: # 松开鼠标时
		z_index = 0
		following_mouse = false
		animate_scale(false)
		
		if target_areas:
			handle_area(target_areas[-1])
		else:
			if current_area:
				animate_to_area(current_area)

func _on_button_down() -> void:
	if purchased:
		return
	be_purchased.emit(self)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.owner is CardArea:
		target_areas.append(area.owner)
	
func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner is CardArea:
		target_areas.erase(area.owner)

func _on_show_detail_timer_timeout() -> void:
	show_detail()
