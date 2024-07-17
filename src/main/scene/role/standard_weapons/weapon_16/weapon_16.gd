extends BowBase

const LIGHTNING_ARROW = preload("res://src/main/scene/role/standard_weapons/weapon_16/lightning_arrow.tscn")
const WEAPON_15_PROJECTILE = preload("res://src/main/scene/role/standard_weapons/weapon_16/weapon_15_projectile.tscn")

var use_weapon_15: bool = false
var target_weapon: SpearBase

func _ready() -> void:
	super()
	
	update_state()
	
func level_up(level: int) -> void:
	super(level)
	
func update_state() -> void:
	if Tools.check_target_weapon_exist(15):
		use_weapon_15 = true
		target_weapon = Tools.get_logic_general_weapon(15)
	else:
		use_weapon_15 = false

func shoot() -> void:
	add_bullet.rpc()
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	for index in attributes["PROJ_COUNT"]:
		var instance: ProjectileBase
		if not use_weapon_15:
			instance = LIGHTNING_ARROW.instantiate()
		else:
			instance = WEAPON_15_PROJECTILE.instantiate()
		instance.player_id = player_id
		instance.slot_id = slot_id
		instance.init_rotation = get_projectile_rotation(graphics.rotation, index, attributes["PROJ_COUNT"])
		instance.init_position = shoot_marker_2d.global_position
		
		Levels.activated_level.add_child(instance, true)


func _on_player_register_weapon(_player_id: int, _weapon_id: int, _slot_id: int) -> void:
	super(_player_id, _weapon_id, _slot_id)

	update_state()

