extends ProjectileBase


const MIASMA = preload("res://src/main/scene/role/effect/miasma/miasma.tscn")

func _ready() -> void:
	super()
	
	update_animation.rpc("idle")

func _on_reach_target() -> void:
	super()
	
	update_animation.rpc("finish")
	


@rpc("authority", "call_local")
func release_miasma() -> void:
	pass
	#var instance = MIASMA.instantiate()
	#instance.player_id = player_id 
	#instance.slot_id = slot_id
	#instance.init_position = global_position
	##instance.damage = miasma_damage
	#instance.is_rectangle = false
	#instance.r_size = Vector2.ZERO
	##instance.c_radius = burning_radius * (1 + attributes["SPAWN_SIZE"])
	#instance.life_time = attributes["EFF_DUR"]
	#
	#Game.add_object(instance)




