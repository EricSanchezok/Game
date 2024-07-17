extends BowBase
const EARTH_ARROW = preload("res://src/main/scene/role/standard_weapons/weapon_26/earth_arrow.tscn")

var fragile_ratio: float = 0.08 ## （调整参数）标记的所造成的伤害占到的最大生命值的百分比
var knockback_multiplier: float = 1.0 ## （调整参数）触发标记的伤害的击退增幅倍率

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func shoot() -> void:
	add_bullet.rpc()
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	for index in attributes["PROJ_COUNT"]:
		var instance: ProjectileBase = EARTH_ARROW.instantiate()
		instance.player_id = player_id
		instance.slot_id = slot_id
		instance.init_rotation = get_projectile_rotation(graphics.rotation, index, attributes["PROJ_COUNT"])
		instance.init_position = shoot_marker_2d.global_position
		
		Game.add_object(instance)
