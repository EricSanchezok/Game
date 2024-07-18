extends SwordBase

const METEORITE = preload("res://src/main/scene/role/standard_weapons/weapon_4/meteorite.tscn")

var spawn_count: int = 2 ## （调整参数）生成的陨石的数量

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func do_enter_attack() -> void:
	for count in spawn_count:
		add_meteorite.rpc()
	
@rpc("authority", "call_local")
func add_meteorite() -> void:
	var instance = METEORITE.instantiate()
	instance.player_id = player_id
	instance.slot_id = slot_id
	instance.init_rotation = 0.0
	instance.init_position = Vector2.ZERO
	
	Game.add_object(instance)
