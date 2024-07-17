class_name BoomerangBase
extends WeaponBase


var recall_time: float = 0

var init_knockback: float

func _ready() -> void:
	super()
	
func level_up(level) -> void:  
	super(level)

enum State {
	WAIT,
	ATTACK,
	RECALL,
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	match state:
		State.WAIT:
			do_tick_wait(delta)
			
			sync_slot_position.rpc()
			sync_direction.rpc(-PI/2, deg_to_rad(attributes["ROT_SPD"]) * delta)
			
		State.ATTACK:
			do_tick_attack(delta)
			
			sync_direction.rpc(graphics.rotation + deg_to_rad(attributes["ROT_SPD"]) * delta)
			sync_position.rpc(global_position + target_dir * attributes["FLY_SPD"] * delta)
			recall_time -= delta
			
		State.RECALL:
			do_tick_recall(delta)
			
			sync_direction.rpc(graphics.rotation + deg_to_rad(attributes["ROT_SPD"]) * delta)
			sync_slot_position.rpc(attributes["FLY_SPD"] * delta)

func get_next_state(state: State) -> int:
	match state:
		State.WAIT:
			target = get_nearest_enemy(true)
			if target and cooling_complete():
				target_dir = (target.global_position - global_position).normalized()
				return State.ATTACK
				
		State.ATTACK:
			if  recall_time <= 0:
				return State.RECALL
				
		State.RECALL:
			if near_slot():
				return State.WAIT
				
	return StateMachine.KEEP_CURRENT
	

func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match from:
		State.WAIT:
			do_leave_wait()
			
		State.ATTACK:
			do_leave_attack()
			
		State.RECALL: 
			do_leave_recall()
			
			recovery_cooldown()
			wam.update_attributes.emit(EffectScope.SELF, "KNOCKBACK", self, AttrType.FIXED, init_knockback)
	
	match to:
		State.WAIT:
			do_enter_wait()
			
			hit_box.monitoring = false
		State.ATTACK:
			do_enter_attack()
			
			recall_time = attributes["EFF_DUR"] / 2
			hit_box.monitoring = true
			
		State.RECALL: 
			do_enter_recall()
			
			init_knockback = attributes["KNOCKBACK"]
			wam.update_attributes.emit(EffectScope.SELF, "KNOCKBACK", self, AttrType.FIXED, -init_knockback)



func do_tick(delta: float) -> void:
	pass
	
func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_attack(delta: float) -> void:
	pass
	
func do_tick_recall(delta: float) -> void:
	pass
	
func do_enter_wait() -> void:
	pass
	
func do_enter_attack() -> void:
	pass
	
func do_enter_recall() -> void:
	pass
	
func do_leave_wait() -> void:
	pass
	
func do_leave_attack() -> void:
	pass
	
func do_leave_recall() -> void:
	pass
