extends SpearBase

func _ready() -> void:
	super()
	
	update_state()

func level_up(level: int) -> void:
	super(level)
	
func do_lock() -> void:
	sync_slot_position.rpc()

func do_enter_lock() -> void:
	sync_direction.rpc(-PI/2)
	
func update_state() -> void:
	if Tools.check_target_weapon_exist(16):
		var target_weapon = Tools.get_logic_general_weapon(weapon_id)
		is_lock = true if target_weapon == self else false
	else:
		is_lock = false

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	if state_machine.current_state == State.RECALL: # 回来时不再产生闪电链
		return
	deferred_add_lighting_chain.call_deferred()
	
func _on_player_register_weapon(_player_id: int, _weapon_id: int, _slot_id: int) -> void:
	super(_player_id, _weapon_id, _slot_id)

	update_state()
		
			



