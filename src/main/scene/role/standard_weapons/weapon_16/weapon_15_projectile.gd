extends ProjectileBase

func _ready() -> void:
	super()

	attributes["PHY_ATK"] += weapon.target_weapon.attributes["PHY_ATK"]
	attributes["MAG_ATK"] += weapon.target_weapon.attributes["MAG_ATK"]
	attributes["FLY_SPD"] = weapon.target_weapon.attack_max_speed
	attributes["PEN_RATE"] = 1.0
	
	projectile_rand = false
	is_dir_mode = true
	#这里系数 0.8 为了减弱速度衰减的力度，为了平衡性考虑的
	deceleration = 0.8 * pow(attributes["FLY_SPD"], 2) / (2 * weapon.target_weapon.thrust_distance)

func _on_reach_target() -> void:
	animation_player.play("finish")

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	deferred_add_lighting_chain.call_deferred()
