extends ProjectileBase


func _ready() -> void:
	super()
	
	tracking = true
	bezier = true
	in_front = true
	in_front_dis = 5
	
	attributes["PHY_ATK"] *= weapon.ice_pick_damage_ratio
	attributes["MAG_ATK"] *= weapon.ice_pick_damage_ratio
	
	if is_multiplayer_authority():
		update_animation.rpc("idle")
		
		
func _on_start_flag_switch_on() -> void:
	target = Tools.get_random_enemy()


func _on_reach_target() -> void:
	super()
	
	update_animation.rpc("finish")
