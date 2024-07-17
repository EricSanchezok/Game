class_name StateMachine
extends Node

const KEEP_CURRENT := -1

var is_lock: bool = false:
	set(v):
		if Tools.switch_on(v, is_lock):
			if "do_enter_lock" in owner: owner.do_enter_lock()
		elif Tools.switch_off(v, is_lock):
			if "do_exit_lock" in owner: owner.do_exit_lock()
		is_lock = v

var state_time: float = 0

var current_state: int = -1:
	set(v):
		owner.transition_state(current_state, v)
		current_state = v
		
		state_time = 0
		
func _ready() -> void:
	await owner.ready
	current_state = 0
	
func _process(delta: float) -> void:
	if is_lock:
		if "do_lock" in owner:	owner.do_lock()
		return
		
	while true:
		var next := owner.get_next_state(current_state) as int
		if next == KEEP_CURRENT:
			break
		current_state = next
			
	owner.tick_physics(current_state, delta)
	
	state_time += delta
