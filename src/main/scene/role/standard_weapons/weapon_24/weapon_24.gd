extends SwordBase
## 20240628: 当前版本CD只是不会影响挥砍速度，还是会影响冷却时间的


var cd_to_damage_ratio: float = 1.2 ## （调整参数）计算出当前cd与基础cd的比率后，附加到攻击力上时的转化率（越高转化为攻击力越多）


var last_damage_ratio: float = 0.0

func _ready() -> void:
	super()
		
	stop_bullets = true
	can_update_speed = false

func _on_ready() -> void:
	super()
	
	update_damage(attributes["ATK_CD"])
	
func level_up(level: int) -> void:
	super(level)
	
func update_damage(value: float) -> void:
	var ratio: float = base_attributes["ATK_CD"] / value
	if ratio > 1.0:
		if last_damage_ratio != 0.0:
			wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, -last_damage_ratio)
			wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, -last_damage_ratio)
		
		var damage_ratio = (ratio - 1.0) * cd_to_damage_ratio
		wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, damage_ratio)
		wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, damage_ratio)
	
		last_damage_ratio = damage_ratio
	else :
		if last_damage_ratio != 0.0:
			wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, -last_damage_ratio)
			wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, -last_damage_ratio)
			
			last_damage_ratio = 0.0

func _on_recalculate_attribute(attr: String, value: float) -> void:
	match attr:
		"ATK_CD":
			update_damage(value)


