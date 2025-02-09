extends BowBase
const TOXIN_ARROW = preload("res://src/main/scene/role/standard_weapons/weapon_28/toxin_arrow.tscn")

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func shoot() -> void:
	add_bullet.rpc()
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	for index in attributes["PROJ_COUNT"]:
		var instance: ProjectileBase = TOXIN_ARROW.instantiate()
		instance.player_id = player_id
		instance.slot_id = slot_id
		instance.init_rotation = get_projectile_rotation(graphics.rotation, index, attributes["PROJ_COUNT"])
		instance.init_position = shoot_marker_2d.global_position
		
		Game.add_object(instance)
