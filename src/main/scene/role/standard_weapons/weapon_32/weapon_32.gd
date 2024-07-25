extends DaggerBase

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)


func _on_critical_success(enemy: EnemyBase) -> void:
	if enemy.is_poision:
		var damage = Damage.new()
		damage.source_weapon = self
		damage.direct_object = damage.source_weapon
				
		damage.is_critical = false
		damage.phy_amount = 0.0
		damage.mag_amount = enemy.effect_queue[enemy.Effect.POISION][0].value * enemy.effect_queue[enemy.Effect.POISION][0].source_weapon.attributes["POISON_DAMAGE"] * int(enemy.effect_queue[enemy.Effect.POISION][0].duration) * attributes["CRIT_DMG"]
		damage.knockback = 0.0
		damage.other = "poision"
				
		enemy.pending_damages.append(damage)
		
		enemy.effect_queue[enemy.Effect.POISION].erase(enemy.effect_queue[enemy.Effect.POISION][0])
		enemy.is_poision = false
	

