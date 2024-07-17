class_name StationBase
extends WeaponBase


enum State{
	WAIT,
	TRIGGER
}

func _ready() -> void:
	super()
	
func level_up(level) -> void:
	super(level)
	
func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	match state:
		State.WAIT:
			do_tick_wait(delta)
					
		State.TRIGGER:
			do_tick_trigger(delta)
			

func get_next_state(state: State) -> int:
	match state:
		State.WAIT:
			if can_enter_trigger():
				return State.TRIGGER
		State.TRIGGER:
			if can_enter_wait():
				return State.WAIT

	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:	
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match to:
		State.WAIT:
			do_enter_wait()

		State.TRIGGER:
			do_enter_trigger()

	
func do_tick(delta: float) -> void:
	pass

func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_trigger(delta: float) -> void:
	pass
	
func can_enter_trigger() -> bool:
	return false
	
func can_enter_wait() -> bool:
	return false
	
func do_enter_wait() -> void:
	pass
	
func do_enter_trigger() -> void:
	pass
