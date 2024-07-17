extends Node

signal global_attribute_changed

var is_in_lobby: bool = false
var player_camera_zoom: Vector2 = Vector2(0.8, 0.8)


var auto_collect_ratio: float = 0.3 # 未拾取的金币在一局结束后自动拾取的比率


## 闪电链搜索下一个敌人的搜索半径增益
var lighting_chain_search_radius_gain_percentage: float = 0.0


## 增加长矛的冲刺距离，长矛的冲刺距离是 索敌距离 x 冲刺倍率，此变量可以增加冲刺倍率的值
var spear_thrust_distance_gain_percentage: float = 0.0:
	set(v):
		spear_thrust_distance_gain_percentage = v
		global_attribute_changed.emit()
## 减少长矛召回时的伤害衰减，长矛召回时的伤害衰减为 原始伤害 * (1 - 衰减倍率)，此变量可以减少衰减倍率的值
var spear_recall_damage_reduce_gain_percentage: float = 0.0:
	set(v):
		spear_recall_damage_reduce_gain_percentage = v
		global_attribute_changed.emit()


