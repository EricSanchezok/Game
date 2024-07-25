extends BoomerangBase

@export var max_damage_increment: float = 5.0
@export var max_scale_increment: float = 5.0
@export var damage_increment: float = 0.1
@export var scale_increment: float = 0.1

var total_damage_increment: float = 0.0
var total_scale_increment: float = 0.0

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func do_leave_recall() -> void:
	wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, -total_damage_increment)
	wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, -total_damage_increment)
	wam.update_attributes.emit(EffectScope.SELF, "ROT_SPD", self, AttrType.MULT, -total_scale_increment)
	wam.update_attributes.emit(EffectScope.SELF, "WEAPON_SIZE", self, AttrType.FIXED, -total_scale_increment)
	
func do_enter_attack() -> void:
	total_damage_increment = 0.0
	total_scale_increment = 0.0


func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	if hit_enemy.is_freeze:
		if total_damage_increment <= max_damage_increment:
			wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, damage_increment)
			wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, damage_increment)
			total_damage_increment += damage_increment
			
		if total_scale_increment <= max_scale_increment:
			wam.update_attributes.emit(EffectScope.SELF, "ROT_SPD", self, AttrType.MULT, scale_increment)
			wam.update_attributes.emit(EffectScope.SELF, "WEAPON_SIZE", self, AttrType.FIXED, scale_increment)
			total_scale_increment += scale_increment



