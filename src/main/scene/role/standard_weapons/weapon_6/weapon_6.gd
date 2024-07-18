extends FirearmBase

const DESTRUCTION_SHELL = preload("res://src/main/scene/role/standard_weapons/weapon_6/destruction_shell.tscn")

func _ready() -> void:
	super()
	
	aim = false

func level_up(level: int) -> void:
	super(level)

func get_enemy() -> EnemyBase:
	return Tools.get_random_enemy()
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	var instance = DESTRUCTION_SHELL.instantiate()
	instance.player_id = player_id
	instance.slot_id = slot_id
	instance.init_rotation = -PI/2
	instance.init_position = shoot_marker_2d.global_position
	
	instance.target = target
	
	Game.add_object(instance)
