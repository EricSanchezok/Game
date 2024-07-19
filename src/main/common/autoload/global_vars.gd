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

## 武器锁，可以禁止购买某些武器
var weapon_locks = {
	0: true, 1: true, 2: true, 3: true, 4: true, 5: true,
	6: true, 7: true, 8: true, 9: true, 10: true, 11: true,
	12: true, 13: true, 14: true, 15: true, 16: true, 17: true,
	18: true, 19: true, 20: true, 21: true, 22: true, 23: true,
	24: true, 25: true, 26: true, 27: true, 28: true, 29: true,
	30: true, 31: true, 32: true, 33: true, 34: true, 35: true,
	36: true, 37: true, 38: true, 39: true, 40: true, 41: true,
	42: true, 43: true, 44: true, 45: true, 46: true, 47: true,
	48: true, 49: true, 50: true, 51: true, 52: true, 53: true,
	54: true, 55: true, 56: true, 57: true, 58: true, 59: true,
	60: true, 61: true
}
