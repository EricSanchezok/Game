extends FirearmBase

const WEAPON_30_BULLET = preload("res://src/main/scene/role/standard_weapons/weapon_30/weapon_30_bullet.tscn")

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	var instance = WEAPON_30_BULLET.instantiate()
	instance.player_id = player_id
	instance.slot_id = slot_id
	instance.init_rotation = graphics.rotation
	instance.init_position = shoot_marker_2d.global_position
	
	instance.is_dir_mode = true

	Game.add_object(instance)
