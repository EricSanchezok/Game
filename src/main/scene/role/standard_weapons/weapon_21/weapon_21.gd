extends SpearBase

var maximum_bonus_time: float = 5.0 ## （调整参数）多少秒后到达最大加成值
var maximum_damage_multiplier: float = 3.0 ## （调整参数）最大加成的伤害倍率
var maximum_attack_cooldown: float = 3.0 ## （调整参数）最大加成的攻速倍率

var current_damage_multiplier: float = 0.0
var current_attack_cooldown: float = 0.0

var reset_attribute: bool = false

func _ready() -> void:
	super()

func _on_ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func do_tick(delta: float) -> void:
	if player.is_moving:
		if reset_attribute:
			wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, -current_damage_multiplier)
			wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, -current_damage_multiplier)
			wam.update_attributes.emit(EffectScope.SELF, "ATK_CD", self, AttrType.MULT, -current_attack_cooldown)
			
			current_damage_multiplier = 0.0
			current_attack_cooldown = 0.0
			reset_attribute = false
			
	else:
		var damage_increment = maximum_damage_multiplier / maximum_bonus_time
		var attack_cooldown_increment = maximum_attack_cooldown / maximum_bonus_time
		
		var actual_damage_increment = clampf(current_damage_multiplier + damage_increment * delta, 0, maximum_damage_multiplier) - current_damage_multiplier
		var actual_attack_cooldown_increment = clampf(current_attack_cooldown + attack_cooldown_increment * delta, 0, maximum_attack_cooldown) - current_attack_cooldown
		
		current_damage_multiplier += actual_damage_increment
		current_attack_cooldown += actual_attack_cooldown_increment
		
		wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, actual_damage_increment)
		wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, actual_damage_increment)
		wam.update_attributes.emit(EffectScope.SELF, "ATK_CD", self, AttrType.MULT, actual_attack_cooldown_increment)
		
		reset_attribute = true

