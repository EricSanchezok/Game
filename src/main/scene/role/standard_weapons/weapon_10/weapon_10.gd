extends BoomerangBase

@export var freeze_rate_increment: float = 0.05
var total_increment: float = 0.0


func _ready() -> void:
	super()

func level_up(level: int) -> void:  
	super(level)
	freeze_rate_increment += 0.05
	
func do_leave_recall() -> void:
	wam.update_attributes.emit(EffectScope.SELF, "FREEZE_RATE", self, AttrType.FIXED, -total_increment)

func do_enter_attack() -> void:
	total_increment = 0.0

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	wam.update_attributes.emit(EffectScope.SELF, "FREEZE_RATE", self, AttrType.FIXED, freeze_rate_increment)
	total_increment += freeze_rate_increment
	
