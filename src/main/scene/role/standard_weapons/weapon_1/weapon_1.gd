extends BookAndScrollBase

var magic_damage_multiplier: float = 3.0 ## （调整参数）魔法伤害的加成倍率
var attack_cooldown_multiplier: float = 1.0 ## （调整参数）攻击速度的加成倍率

func _ready() -> void:
	super()
	
func level_up(level: int) -> void:  #升级增加持续时间和效果
	super(level)
	
	magic_damage_multiplier += 0.1
	
func do_enter_trigger() -> void:
	wam.update_attributes.emit(EffectScope.GLOBAL, "MAG_ATK", self, AttrType.MULT, magic_damage_multiplier)
	wam.update_attributes.emit(EffectScope.GLOBAL, "ATK_CD", self, AttrType.MULT, attack_cooldown_multiplier)
	
	# 测试用
	wam.update_attributes.emit(EffectScope.GLOBAL, "PHY_ATK", self, AttrType.MULT, 3.0)
	wam.update_attributes.emit(EffectScope.GLOBAL, "SPAWN_SIZE", self, AttrType.FIXED, 1.0)
	wam.update_attributes.emit(EffectScope.GLOBAL, "PROJ_COUNT", self, AttrType.FIXED, 3.0)
	
	
func do_leave_trigger() -> void:
	wam.update_attributes.emit(EffectScope.GLOBAL, "MAG_ATK", self, AttrType.MULT, -magic_damage_multiplier)
	wam.update_attributes.emit(EffectScope.GLOBAL, "ATK_CD", self, AttrType.MULT, -attack_cooldown_multiplier)
	
	# 测试用
	wam.update_attributes.emit(EffectScope.GLOBAL, "PHY_ATK", self, AttrType.MULT, -3.0)
	wam.update_attributes.emit(EffectScope.GLOBAL, "SPAWN_SIZE", self, AttrType.FIXED, -1.0)
	wam.update_attributes.emit(EffectScope.GLOBAL, "PROJ_COUNT", self, AttrType.FIXED, -3.0)


	
