extends DaggerBase
## 20240626: 当前版本中，当前武器成功冻结敌人后增益的时间更改为“调整参数”，且可以叠加

var critical_rate_increment: float = 0.2 ## （调整参数）成功冻结敌人后增加的暴击率
var critical_damage_increment: float = 1.0 ## （调整参数）成功冻结敌人后增加的暴击伤害
var increment_time: float = 1.5 ## （调整参数）成功冻结敌人后增加伤害的持续时间


var increment_time_left: float = 0.0

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)
	
	critical_rate_increment += 0.2
	critical_damage_increment += 0.5
	
func do_tick(delta: float) -> void:
	if increment_time_left > 0:
		increment_time_left -= delta
	
	if increment_time_left < 0:
		wam.update_attributes.emit(EffectScope.SELF, "CRIT_RATE", self, AttrType.FIXED, -critical_rate_increment)
		wam.update_attributes.emit(EffectScope.SELF, "CRIT_DMG", self, AttrType.MULT, -critical_damage_increment)
		increment_time_left = 0.0

func _on_freeze_success(enemy: EnemyBase): #攻击冻结敌人暴击伤害提高
	if increment_time_left == 0.0:
		wam.update_attributes.emit(EffectScope.SELF, "CRIT_RATE", self, AttrType.FIXED, critical_rate_increment)
		wam.update_attributes.emit(EffectScope.SELF, "CRIT_DMG", self, AttrType.MULT, critical_damage_increment)
		
	increment_time_left += increment_time
