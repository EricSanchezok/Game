class_name BoostCard
extends Button

@onready var card_texture: TextureRect = $CardTexture
@onready var detail_label: Label = $CardTexture/DetailLabel
@onready var name_label: Label = $CardTexture/NameLabel

var my_player: PlayerBase
var lock: bool = false
var boost_data: Dictionary

var id: int
var type: String = "BondBoosts":
	set(v):
		type = v
		if not is_node_ready(): await ready
		var rect2 = Rect2()
		match type:
			"BondBoosts":
				rect2 = Rect2(0, 0, 64, 96)
			"PowerBoosts":
				rect2 = Rect2(128, 0, 64, 96)
			"EconomyBoosts":
				rect2 = Rect2(64, 0, 64, 96)
			_:
				printerr("No match BoostType!")
		card_texture.texture.region = rect2
		
var tween_scale: Tween
		
func _ready() -> void:
	card_texture.texture = card_texture.texture.duplicate()

func update() -> void:
	type = boost_data["type"]
	id = boost_data["id"]
	name_label.text = boost_data["name"]
	detail_label.text = boost_data["detail"]
	
func animate_scale(is_expand: bool) -> void:
	if tween_scale and tween_scale.is_running():
		tween_scale.kill()
	
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	
	if is_expand:
		tween_scale.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
	else:
		tween_scale.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
func recovery() -> void:
	lock = false
	scale = Vector2.ONE

func _on_pressed() -> void:
	my_player.bam.register_boost.emit(boost_data)
	
	lock = true
	
	if tween_scale and tween_scale.is_running():
		tween_scale.kill()
	
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_scale.tween_property(self, "scale", Vector2(1.5, 1.5), 0.2)
	
	await tween_scale.finished
	
	tween_scale = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_scale.tween_property(self, "scale", Vector2(0.0, 0.0), 0.2)
	
	await tween_scale.finished
	
	owner.hide_screen()
	
	
func _on_card_texture_mouse_entered() -> void:
	if lock:
		return
	animate_scale(true)

func _on_card_texture_mouse_exited() -> void:
	if lock:
		return
	animate_scale(false)
