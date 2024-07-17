class_name BowBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var tween_shoot: Tween
var init_sprite_position: Vector2

func _ready() -> void:
	super()
	
	init_sprite_position = sprite_2d.position
	
func level_up(level) -> void:  #升级增加发射物数量
	super(level)

enum State{
	WAIT,
	AIMNG,
	SHOOT
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	sync_slot_position.rpc()
	
	if not target:
		sync_direction.rpc(0, deg_to_rad(attributes["ROT_SPD"]) * delta)
	else :
		target_dir = (target.global_position - global_position).normalized()
		sync_direction.rpc(target_dir.angle(), deg_to_rad(attributes["ROT_SPD"]) * delta)
		
	match state:
		State.WAIT:
			do_tick_wait(delta)
			
		State.AIMNG:
			do_tick_aiming(delta)
			
		State.SHOOT:
			do_tick_shoot(delta)

func get_next_state(state: State) -> int:
	match state:
		State.WAIT:
			target = get_enemy()
			if target:
				target_dir = (target.global_position - global_position).normalized()
				return State.AIMNG
				
		State.AIMNG:
			if not target or target.is_dead:
				return State.WAIT
			if aim_success() and cooling_complete():
				return State.SHOOT
				
		State.SHOOT:
			if not animation_player.is_playing():
				return State.WAIT
			
	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match to:
		State.WAIT:
			do_enter_wait()
			
			recovery_cooldown()
			
		State.AIMNG:
			do_enter_aiming()
			
		State.SHOOT:
			do_enter_shoot()
			
			shoot_flag = true
			tween_shoot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			tween_shoot.tween_property(sprite_2d, "position", init_sprite_position, 0.2).from(init_sprite_position - Vector2(-10, 0))

			# update_animation.rpc("shoot")
			
@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)
	
func get_enemy() -> EnemyBase:
	return get_nearest_enemy()
	
func do_tick(delta: float) -> void:
	pass
	
func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_aiming(delta: float) -> void:
	pass
	
func do_tick_shoot(delta: float) -> void:
	pass
	
func do_enter_wait() -> void:
	pass
	
func do_enter_aiming() -> void:
	pass
	
func do_enter_shoot() -> void:
	pass
