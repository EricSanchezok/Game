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
	
# 达到特定阈值时触发的函数
func _on_threshold_reached(type: String, value: int) -> void:
	print("Threshold reached for %s at value %d" % [type, value])
	match type:
		"FIRE":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"FROST":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"LIGHTING":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"EARTH":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"TOXIN":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"NATURE":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"DIVINITY":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"DEMON":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"SWORD":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"SHIELD":
			match value:
				2:
					pass
				4:
					pass
		"AXE":
			match value:
				2:
					pass
				4:
					pass
		"SPEAR":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"DAGGER":
			match value:
				2:
					pass
				4:
					pass
		"BOW":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"STAFF":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"SCROLL":
			match value:
				2:
					pass
				3:
					pass
				4:
					pass
		"FIREARM":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
		"STATION":
			match value:
				2:
					pass
				4:
					pass
		"BOOK":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
		"BOOMERANG":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass

# 掉回到特定值以下时触发的函数
func _on_threshold_dropped(type: String, value: int) -> void:
	print("Threshold dropped for %s from value %d" % [type, value])
	match type:
		"FIRE":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"FROST":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"LIGHTING":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"EARTH":
			match value:
				3:
					pass
				5:
					pass
				7:
					pass
				9:
					pass
		"TOXIN":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"NATURE":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"DIVINITY":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"DEMON":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"SWORD":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"SHIELD":
			match value:
				2:
					pass
				4:
					pass
		"AXE":
			match value:
				2:
					pass
				4:
					pass
		"SPEAR":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"DAGGER":
			match value:
				2:
					pass
				4:
					pass
		"BOW":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"STAFF":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
				8:
					pass
		"SCROLL":
			match value:
				2:
					pass
				3:
					pass
				4:
					pass
		"FIREARM":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
		"STATION":
			match value:
				2:
					pass
				4:
					pass
		"BOOK":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
		"BOOMERANG":
			match value:
				2:
					pass
				4:
					pass
				6:
					pass
