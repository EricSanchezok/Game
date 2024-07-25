extends StaffBase

const WEAPON_29_BULLET = preload("res://src/main/scene/role/standard_weapons/weapon_29/weapon_29_bullet.tscn")


func _ready() -> void:
	super()
	
	is_staff_like = true

func level_up(level: int) -> void:
	super(level)

func shoot() -> void:
	add_bullet.rpc()
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	for index in attributes["PROJ_COUNT"]:
		var instance = WEAPON_29_BULLET.instantiate()
		instance.player_id = player_id
		instance.slot_id = slot_id
		instance.init_rotation = randf_range(-PI, PI)
		instance.init_position = shoot_marker_2d.global_position
		
		instance.target = get_random_enemy()
		
		Game.add_object(instance)
