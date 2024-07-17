class_name CollisionMonster
extends EnemyBase

func _ready() -> void:
	super()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 状态机 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
enum State {
	APPEAR,
	RUN,
	HURT,
	DIE,
}

var invincible_states = [State.APPEAR, State.DIE]


func tick_physics(state: State, delta: float) -> void:
	if must_do_nothing():
		return
		
	update_effects(delta)
	apply_effects(delta)
	apply_damages()
	
	# >>>>>>>>>>>>>>>>>>>> 敌人状态机 >>>>>>>>>>>>>>>>>>>>
	match state:
		State.APPEAR, State.DIE:
			pass
		State.HURT:
			pass
		State.RUN:
			calculate_velocity_to_target(delta)
			
	if is_freeze:
		velocity *= effect_queue[Effect.FREEZE][0].value

	move_and_collide(velocity*delta)

func get_next_state(state: State) -> int:
	if must_do_nothing():
		return StateMachine.KEEP_CURRENT

	if attributes["HP"] <= 0:
		return StateMachine.KEEP_CURRENT if state == State.DIE else State.DIE
		
	if is_freeze:
		return StateMachine.KEEP_CURRENT

	if pending_damages.size() > 0 and state not in invincible_states:
		return StateMachine.KEEP_CURRENT if state == State.HURT else State.HURT

	match state:
		State.APPEAR:
			if not animation_player.is_playing():
				return State.RUN
		State.RUN:
			pass
		State.HURT:
			if not animation_player.is_playing():
				return State.RUN
		State.DIE:
			pass

	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	if must_do_nothing():
		return
		
	match from:
		State.APPEAR:
			target = get_nearest_player()
			toward_target_player()

	match to:
		State.APPEAR:
			enter_appear()
			
		State.RUN:
			enter_run()
			
		State.HURT:
			enter_hurt()
			
		State.DIE:
			enter_die()
