class_name TraitAttributeManager
extends Node

# 初始化状态字典，用于存储每个trait的当前状态
var traits_thresholds = {
	"FIRE": 0, "FROST": 0, "LIGHTING": 0, "EARTH": 0, "TOXIN": 0, "NATURE": 0, "DIVINITY": 0, "DEMON": 0,
	"SWORD": 0, "SHIELD": 0, "AXE": 0, "SPEAR": 0, "DAGGER": 0, "BOW": 0, "STAFF": 0, "SCROLL": 0, 
	"FIREARM": 0, "STATION": 0, "BOOK": 0, "BOOMERANG": 0
}

# 为每个trait设置阈值
var trait_thresholds = {
	"FIRE": [3, 5, 7, 9],
	"FROST": [3, 5, 7, 9],
	"LIGHTING": [3, 5, 7, 9],
	"EARTH": [3, 5, 7, 9],
	"TOXIN": [2, 4, 6, 8],
	"NATURE": [2, 4, 6, 8],
	"DIVINITY": [2, 4, 6, 8],
	"DEMON": [2, 4, 6, 8],
	"SWORD": [2, 4, 6, 8],
	"SHIELD": [2, 4],
	"AXE": [2, 4],
	"SPEAR": [2, 4, 6, 8],
	"DAGGER": [2, 4],
	"BOW": [2, 4, 6, 8],
	"STAFF": [2, 4, 6, 8],
	"SCROLL": [2, 3, 4],
	"FIREARM": [2, 4, 6],
	"STATION": [2, 4],
	"BOOK": [2, 4, 6],
	"BOOMERANG": [2, 4, 6]
}

# 信号连接
func _ready() -> void:
	owner.traits_count_changed.connect(_on_traits_count_changed)

func _on_traits_count_changed(type: String, value: int) -> void:
	var current_value = owner.traits_count[type]
	
	# 获取该trait之前的状态
	var previous_threshold = traits_thresholds[type]
	
	# 获取对应的阈值列表
	var thresholds = trait_thresholds[type]
	
	# 检查是否达到了特定阈值
	for threshold in thresholds:
		if current_value == threshold and current_value > previous_threshold:
			_on_threshold_reached(type, current_value)
			traits_thresholds[type] = current_value
			return # 阻止重复执行多个阈值函数
	
	# 检查是否掉回到特定值以下
	if current_value < previous_threshold and previous_threshold in thresholds:
		_on_threshold_dropped(type, previous_threshold)
	
	traits_thresholds[type] = current_value

func fire_reached(value: int) -> void:
	print("Fire reached at value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func fire_dropped(value: int) -> void:
	print("Fire dropped from value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func frost_reached(value: int) -> void:
	print("Frost reached at value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func frost_dropped(value: int) -> void:
	print("Frost dropped from value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func lighting_reached(value: int) -> void:
	print("Lighting reached at value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func lighting_dropped(value: int) -> void:
	print("Lighting dropped from value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func earth_reached(value: int) -> void:
	print("Earth reached at value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func earth_dropped(value: int) -> void:
	print("Earth dropped from value %d" % value)
	match value:
		3:
			pass
		5:
			pass
		7:
			pass
		9:
			pass

func toxin_reached(value: int) -> void:
	print("Toxin reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func toxin_dropped(value: int) -> void:
	print("Toxin dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func nature_reached(value: int) -> void:
	print("Nature reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func nature_dropped(value: int) -> void:
	print("Nature dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func divinity_reached(value: int) -> void:
	print("Divinity reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func divinity_dropped(value: int) -> void:
	print("Divinity dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func demon_reached(value: int) -> void:
	print("Demon reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func demon_dropped(value: int) -> void:
	print("Demon dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func sword_reached(value: int) -> void:
	print("Sword reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func sword_dropped(value: int) -> void:
	print("Sword dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func shield_reached(value: int) -> void:
	print("Shield reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func shield_dropped(value: int) -> void:
	print("Shield dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func axe_reached(value: int) -> void:
	print("Axe reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func axe_dropped(value: int) -> void:
	print("Axe dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func spear_reached(value: int) -> void:
	print("Spear reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func spear_dropped(value: int) -> void:
	print("Spear dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func dagger_reached(value: int) -> void:
	print("Dagger reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func dagger_dropped(value: int) -> void:
	print("Dagger dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func bow_reached(value: int) -> void:
	print("Bow reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func bow_dropped(value: int) -> void:
	print("Bow dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func staff_reached(value: int) -> void:
	print("Staff reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func staff_dropped(value: int) -> void:
	print("Staff dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass
		8:
			pass

func scroll_reached(value: int) -> void:
	print("Scroll reached at value %d" % value)
	match value:
		2:
			pass
		3:
			pass
		4:
			pass

func scroll_dropped(value: int) -> void:
	print("Scroll dropped from value %d" % value)
	match value:
		2:
			pass
		3:
			pass
		4:
			pass

func firearm_reached(value: int) -> void:
	print("Firearm reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass

func firearm_dropped(value: int) -> void:
	print("Firearm dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass

func station_reached(value: int) -> void:
	print("Station reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func station_dropped(value: int) -> void:
	print("Station dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass

func book_reached(value: int) -> void:
	print("Book reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass

func book_dropped(value: int) -> void:
	print("Book dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass

func boomerang_reached(value: int) -> void:
	print("Boomerang reached at value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass

func boomerang_dropped(value: int) -> void:
	print("Boomerang dropped from value %d" % value)
	match value:
		2:
			pass
		4:
			pass
		6:
			pass

	
# 达到特定阈值时触发的函数
func _on_threshold_reached(type: String, value: int) -> void:
	print("Threshold reached for %s at value %d" % [type, value])
	match type:
		"FIRE":
			fire_reached(value)
		"FROST":
			frost_reached(value)
		"LIGHTING":
			lighting_reached(value)
		"EARTH":
			earth_reached(value)
		"TOXIN":
			toxin_reached(value)
		"NATURE":
			nature_reached(value)
		"DIVINITY":
			divinity_reached(value)
		"DEMON":
			demon_reached(value)
		"SWORD":
			sword_reached(value)
		"SHIELD":
			shield_reached(value)
		"AXE":
			axe_reached(value)
		"SPEAR":
			spear_reached(value)
		"DAGGER":
			dagger_reached(value)
		"BOW":
			bow_reached(value)
		"STAFF":
			staff_reached(value)
		"SCROLL":
			scroll_reached(value)
		"FIREARM":
			firearm_reached(value)
		"STATION":
			station_reached(value)
		"BOOK":
			book_reached(value)
		"BOOMERANG":
			boomerang_reached(value)

# 掉回到特定值以下时触发的函数
func _on_threshold_dropped(type: String, value: int) -> void:
	print("Threshold dropped for %s from value %d" % [type, value])
	match type:
		"FIRE":
			fire_dropped(value)
		"FROST":
			frost_dropped(value)
		"LIGHTING":
			lighting_dropped(value)
		"EARTH":
			earth_dropped(value)
		"TOXIN":
			toxin_dropped(value)
		"NATURE":
			nature_dropped(value)
		"DIVINITY":
			divinity_dropped(value)
		"DEMON":
			demon_dropped(value)
		"SWORD":
			sword_dropped(value)
		"SHIELD":
			shield_dropped(value)
		"AXE":
			axe_dropped(value)
		"SPEAR":
			spear_dropped(value)
		"DAGGER":
			dagger_dropped(value)
		"BOW":
			bow_dropped(value)
		"STAFF":
			staff_dropped(value)
		"SCROLL":
			scroll_dropped(value)
		"FIREARM":
			firearm_dropped(value)
		"STATION":
			station_dropped(value)
		"BOOK":
			book_dropped(value)
		"BOOMERANG":
			boomerang_dropped(value)
