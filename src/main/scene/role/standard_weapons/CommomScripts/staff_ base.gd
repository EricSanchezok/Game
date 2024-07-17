class_name StaffBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var is_staff_like: bool = false

func _ready() -> void:
	super()
	
func level_up(level) -> void:
	super(level)

enum State{
	WAIT,
	ATTACK
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	sync_slot_position.rpc()
		
	match state:
		State.WAIT:
			do_tick_wait(delta)
			
		State.ATTACK:
			do_tick_attack(delta)

func get_next_state(state: State) -> int:
	match state:
		State.WAIT:
			if has_enemy() and cooling_complete():
				return State.ATTACK
			
		State.ATTACK:
			if not animation_player.is_playing():
				return State.WAIT

	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:	
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match from:
		State.WAIT:
			pass
			
		State.ATTACK:
			recovery_cooldown()
	
	match to:
		State.WAIT:
			do_enter_wait()
			
			sprite_2d.use_parent_material = false
			
		State.ATTACK:
			do_enter_attack()
			
			sprite_2d.use_parent_material = true
			if not is_staff_like:
				update_animation.rpc("shoot")
			else:
				update_animation.rpc("staff_shoot/shoot")
			
@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)
	
func do_tick(delta: float) -> void:
	pass

func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_attack(delta: float) -> void:
	pass
	
func do_enter_wait() -> void:
	pass
	
func do_enter_attack() -> void:
	pass

