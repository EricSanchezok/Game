class_name BookAndScrollBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var scroll: bool = false
@export var is_book_like: bool = false

func _ready() -> void:
	super() # WeaponBase 里的 ready 是初始化参数的关键函数，每个都要执行
	
	player.kill_success.connect(_on_player_kill_success)
	
func level_up(level) -> void:
	super(level)
	
	if not scroll:
		pass
		
	else:
		pass

enum State{
	WAIT,
	TRIGGER
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
		
	do_tick(delta)
		
	sync_slot_position.rpc()
	match state:
		State.WAIT:
			do_tick_wait(delta)
			
		State.TRIGGER:
			do_tick_trigger(delta)
			
func get_next_state(state: State) -> int: 
	match state:
		State.WAIT:
			if cooling_complete():
				return State.TRIGGER
				
		State.TRIGGER:
			if timer_effect.is_stopped():
				return State.WAIT

	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match from:
		State.WAIT:
			do_leave_wait()
			
		State.TRIGGER:
			do_leave_trigger()
	
	match to:
		State.WAIT:
			do_enter_wait()
			
			sprite_2d.use_parent_material = false
			animation_player.stop()
			recovery_cooldown()
			var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property($Graphics, "position", Vector2.ZERO, 1.0)
			tween.parallel().tween_property($Graphics, "scale", Vector2.ONE, 1.0)

		State.TRIGGER:
			do_enter_trigger()
			
			sprite_2d.use_parent_material = true
			if not is_book_like:
				animation_player.play("book_floating")
			else:
				animation_player.play("book_floating/book_floating")
			timer_effect.start()
			

	
func do_tick(delta: float) -> void:
	pass
	
func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_trigger(delta: float) -> void:
	pass
	
func do_leave_wait() -> void:
	pass
	
func do_leave_trigger() -> void:
	pass
	
func do_enter_wait() -> void:
	pass
	
func do_enter_trigger() -> void:
	pass

func _on_player_kill_success(enemy: EnemyBase) -> void:
	if not scroll:
		return
	attack_cooldown_time -= attributes["SCROLL_CD_REDUC"]
