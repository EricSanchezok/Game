class_name FirearmBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var aim: bool = false
@export var random_enemy:bool = false

func _ready() -> void:
	super()
	
func level_up(level) -> void:  #升级增加弹匣
	super(level)

enum State {
	WAIT,
	ATTACK
}

var shoot_count: int = 0:
	set(v):
		if v >= attributes["PROJ_COUNT"]:
			shoot_count = 0
		else:
			shoot_count = v

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	sync_slot_position.rpc()
	if aim and is_instance_valid(target):
		target_dir = (target.global_position - global_position).normalized()
		sync_direction.rpc(target_dir.angle(), deg_to_rad(attributes["ROT_SPD"]) * delta)
	
	match state:
		State.WAIT:
			do_tick_wait(delta)
			
		State.ATTACK:
			do_tick_attack(delta)
			
func get_next_state(state: State) -> int:
	match state:
		State.WAIT:
			if has_enemy():
				if (shoot_count > 0 and shoot_count < attributes["PROJ_COUNT"]) or cooling_complete():
					if random_enemy:
						target = get_random_enemy()
					else:
						target = get_enemy()
					target_dir = (target.global_position - global_position).normalized()
					if aim and aim_success():
						return State.ATTACK
					else:
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
			
		State.ATTACK:
			do_enter_attack()
			
			shoot_count += 1
			update_animation.rpc("shoot")
			

@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)
	
func get_enemy() -> EnemyBase:
	return get_nearest_enemy()

func shoot() -> void:
	super()
	
	if is_instance_valid(target):
		add_bullet.rpc()
	else:
		target = get_enemy()
		if target:
			add_bullet.rpc()

@rpc("authority", "call_local")
func add_bullet() -> void:
	pass
	
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


