class_name ShooterMonster
extends EnemyBase

@onready var shoot_wait_timer: Timer = $Timers/ShootWaitTimer

func _ready() -> void:
	super()
	
func _on_ready() -> void:
	super()
	shoot_wait_timer.wait_time = attributes["SHOOT_WAIT"]

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 状态机 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
enum State {
	APPEAR,
	RUN,
	IDLE,
	ATTACK,
	HURT,
	DIE,
}

var invincible_states = [State.APPEAR, State.DIE, State.ATTACK]


func tick_physics(state: State, delta: float) -> void:
	if must_do_nothing():
		return
		
	update_effects(delta)
	apply_effects(delta)
	apply_damages()
	
	
	# >>>>>>>>>>>>>>>>>>>> 敌人状态机 >>>>>>>>>>>>>>>>>>>>
	match state:
		State.APPEAR, State.DIE, State.HURT:
			velocity = Vector2.ZERO
			
		State.ATTACK:
			velocity = Vector2.ZERO

		State.RUN:
			calculate_velocity_to_target(delta)
			
		State.IDLE:
			velocity = Vector2.ZERO
			
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
			if global_position.distance_squared_to(target.global_position) <= pow(attributes["SHOOT_DIST"], 2):
				return State.ATTACK
		
		State.ATTACK:
			if not animation_player.is_playing():
				return State.IDLE
				
		State.IDLE:
			if shoot_wait_timer.is_stopped():
				return State.RUN
			
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
			
		State.ATTACK:
			shoot_wait_timer.start()

	match to:
		State.APPEAR:
			enter_appear()
			
		State.RUN:
			enter_run()
			
		State.ATTACK:
			toward_target_player()
			update_animation.rpc("attack")
				
		State.IDLE:
			shoot_wait_timer.start()
			if not is_shade_like:
				update_animation.rpc("idle")
			else:
				update_animation.rpc("ShadeLike/idle")
			
		State.HURT:
			enter_hurt()
			
		State.DIE:
			enter_die()
			
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 功能函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func shoot() -> void:
	var instance = (load(attributes["SHOOT_PATH"]) as PackedScene).instantiate()
	instance.rand_float = rand_float
	instance.dir = (target.global_position - global_position).normalized()
	instance.speed = attributes["SHOOT_SPD"]
	instance.life = attributes["SHOOT_LIFE"]
	instance.global_position = shoot_marker.global_position
	instance.attributes["DMG"] = attributes["SHOOT_DMG"]
	
	Game.add_child(instance)
