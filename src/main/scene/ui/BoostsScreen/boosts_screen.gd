extends Control

@onready var boosts_container: HBoxContainer = $HBoxContainer

var hide_pos = Vector2(0, -100)

var my_player: PlayerBase
@onready var boost_cards: Array = [
	$HBoxContainer/Panel0/BoostCard_0,
	$HBoxContainer/Panel1/BoostCard_1,
	$HBoxContainer/Panel2/BoostCard_2
]

var boost_data_base: Array = [] # 强化基础数据库

var bond_boosts: Array = []
var power_boosts: Array = []
var economy_boosts: Array = []

func _ready() -> void:
	hide()
	
	my_player = owner
	for boost_card in boost_cards:
		boost_card.my_player = my_player
		
	boost_data_base = load_boost_data_base("res://src/main/StrengtheningDataBase.xlsx")
	extract_data_base(boost_data_base)
	
	Game.start_game.connect(_on_start_game)

func show_screen() -> void:
	show()
	
	for boost_card in boost_cards:
		boost_card.recovery()
		
		var index = boost_cards.find(boost_card)
		
		var tween_show = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_show.parallel().tween_property(boost_card, "position", Vector2(0, 0), 0.4 + 0.3 * index).from(hide_pos)
		tween_show.parallel().tween_property(boost_card, "modulate:a", 1.0, 0.4 + 0.3 * index).from(0.0)
	
func hide_screen() -> void:
	for boost_card in boost_cards:
		var index = boost_cards.find(boost_card)
		
		var tween_show = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_show.parallel().tween_property(boost_card, "position", hide_pos, 0.5)
		tween_show.parallel().tween_property(boost_card, "modulate:a", 0.0, 0.5)

		if index == boost_cards.size() - 1:
			await tween_show.finished
			hide()
		
func get_random_type() -> String:
	var types = ["BondBoosts", "PowerBoosts", "EconomyBoosts"]
	return types[randi_range(0, 2)]
	
func redraw_boosts(type: String = "") -> void:
	for boost_card in boost_cards:
		if type:
			boost_card.boost_data = draw_boost(type)
		else:
			var random_type = get_random_type()
			boost_card.boost_data = draw_boost(random_type)
		boost_card.update()

func draw_boost(type: String) -> Dictionary:
	var boost: Dictionary = {}
	
	match type:
		"BondBoosts":
			boost = bond_boosts.pick_random()
			bond_boosts.erase(boost)

		"PowerBoosts":
			boost = power_boosts.pick_random()
			power_boosts.erase(boost)

		"EconomyBoosts":
			boost = economy_boosts.pick_random()
			economy_boosts.erase(boost)
	
	return boost

	
func extract_data_base(data_base: Array) -> void:
	bond_boosts.clear()
	power_boosts.clear()
	economy_boosts.clear()
	
	for data in data_base:
		if not data["enable"] or not data["finish"]:
			continue
			
		var extract_data = {
			"id": data["id"],
			"type": data["type"],
			"name": data["name"],
			"detail": data["detail"]
		}

		match extract_data["type"]:
			"BondBoosts":
				bond_boosts.append(extract_data)
			"PowerBoosts":
				power_boosts.append(extract_data)
			"EconomyBoosts":
				economy_boosts.append(extract_data)

func load_boost_data_base(path: String) -> Array:
	'''
	加载武器基础数据

	:param path: 武器基础数据表路径
	:return: None
	'''
	var data_base: Array = []

	var excel = ExcelFile.open_file(path)
	var workbook = excel.get_workbook()

	var sheet = workbook.get_sheet(0)
	var table_data = sheet.get_table_data()
	for row_index in range(2, 71):
		var data = {}
		for j in range(table_data[1].size()):
			data[table_data[1][j+1]] = table_data[row_index][j+1]
		
		data_base.append(data)
	
	return data_base

func _on_start_game(level: Node2D) -> void:
	extract_data_base(boost_data_base)
