extends AxeBase

const GATHERING_THUNDER = preload("res://src/main/scene/role/standard_weapons/weapon_19/gathering_thunder.tscn")

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)
	
func do_enter_landing() -> void:
	add_gathering_thunder.rpc()

@rpc("authority", "call_local")
func add_gathering_thunder() -> void:
	var instance = GATHERING_THUNDER.instantiate()
	instance.player_id = player_id
	instance.slot_id = slot_id
	instance.init_rotation = 0
	instance.init_position = global_position
	
	instance.target_pos = global_position

	Game.add_object(instance)
	
func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	deferred_add_lighting_chain.call_deferred()
