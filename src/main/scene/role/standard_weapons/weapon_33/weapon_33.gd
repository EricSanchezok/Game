extends BoomerangBase

var total_posion_lay_increment: float = 0.0

var damage_up: float = 1.5

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func do_enter_wait() -> void:
	wam.update_attributes.emit(EffectScope.SELF, "POISON_LAY", self,AttrType.FIXED, -total_posion_lay_increment)
	total_posion_lay_increment = 0
	

func _on_kill_success(enemy: EnemyBase) -> void:
	super(enemy)
	
	wam.update_attributes.emit(EffectScope.SELF, "POISON_LAY", self,AttrType.FIXED, enemy.effect_queue[enemy.Effect.POISION][0].value)
	
	total_posion_lay_increment += enemy.effect_queue[enemy.Effect.POISION][0].value


func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	for effect in hit_enemy.effect_queue:
		if effect.size() != 0:
			for damage in hit_enemy.pending_damages:
				if damage.source_weapon == self:
					damage.phy_amount *= damage_up
					damage.mag_amount *= damage_up
