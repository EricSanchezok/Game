class_name DashMonster
extends EnemyBase

@onready var dash_line: Line2D = $DashLine
@onready var dash_before_timer: Timer = $Timers/DashBeforeTimer
@onready var dash_wait_timer: Timer = $Timers/DashWaitTimer

var dash_dir: Vector2
var dash_speed: Vector2
var dash_end_point: Vector2
var deceleration: float
var current_pre_time: float

func _ready() -> void:
	super()
	
func _on_ready() -> void:
	super()
	
	dash_wait_timer.wait_time = attributes["DASH_WAIT"]
	dash_before_timer.wait_time = attributes["DASH_PAUSE"]
	
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 状态机 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
enum State {
	APPEAR,
	RUN,
	PRE_DASH,
	DASH,
	END_DASH,
	HURT,
	DIE,
}
var invincible_states = [State.APPEAR, State.DIE, State.PRE_DASH, State.DASH, State.END_DASH]

func tick_physics(state: State, delta: float) -> void:
	if must_do_nothing():
		return
		
	update_effects(delta)
	apply_effects(delta)
	apply_damages()


	# >>>>>>>>>>>>>>>>>>>> 敌人状态机 >>>>>>>>>>>>>>>>>>>>
	match state:
		State.APPEAR, State.DIE, State.HURT:
			pass
			
		State.PRE_DASH:
			velocity = Vector2.ZERO
			toward_target_player()
			
			dash_dir = (target.global_position - global_position).normalized()
			dash_end_point = dash_dir.normalized() * attributes["DASH_DIST"] * current_pre_time / attributes["DASH_PAUSE"]
			dash_line.points = Tools.linear_generate_points(Vector2.ZERO, dash_end_point, 20)
			current_pre_time += delta
			
		State.DASH:
			velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
			dash_end_point -= velocity * delta
			dash_line.points = Tools.linear_generate_points(Vector2.ZERO, dash_end_point, 20)
			
		State.END_DASH:
			velocity = Vector2.ZERO

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
			if dash_wait_timer.is_stopped():
				if global_position.distance_squared_to(target.global_position) <= pow(attributes["DASH_PRE_DIST"], 2):
					return State.PRE_DASH

		State.PRE_DASH:
			if not animation_player.is_playing() and dash_before_timer.is_stopped():
				return State.DASH

		State.DASH:
			if not animation_player.is_playing():
				return State.END_DASH
			
		State.END_DASH:
			if not animation_player.is_playing():
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
			
		State.END_DASH:
			# 击退抗性恢复
			update_attributes.emit("KNB_RES", "DASH", AttrType.FIXED, -1.0)
			dash_wait_timer.start()

	match to:
		State.APPEAR:
			enter_appear()
			
		State.RUN:
			enter_run()
			
		State.PRE_DASH:
			# 无法被击退
			update_attributes.emit("KNB_RES", "DASH", AttrType.FIXED, 1.0)
			update_animation.rpc("pre_dash")
			current_pre_time = 0.0
			dash_before_timer.start()
			dash_line.visible = true

		State.DASH:
			$CollisionShape2D.disabled = true
			update_animation.rpc("dash")
			deceleration = (attributes["DASH_INIT_SPD"] * attributes["DASH_TIME"] - attributes["DASH_DIST"]) * 2 / pow(attributes["DASH_TIME"], 2)
			velocity = attributes["DASH_INIT_SPD"] * dash_dir
			
		State.END_DASH:
			update_animation.rpc("end_dash")
			$CollisionShape2D.disabled = false
			dash_line.visible = false

		State.HURT:
			enter_hurt()
			
		State.DIE:
			enter_die()
	
