class_name DaggerBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var distance_reminder: Sprite2D = $distance_reminder
@onready var base_reminder_scale = distance_reminder.scale

# 运动参数
var thrust_max_speed: float = 1000 ## 冲刺起始速度
var thrust_min_speed: float = 100 ## 冲刺结束速度
var thrust_distance: float = 120 ## 冲刺距离
var reminder_threshold: float = 0.5 ## 超出范围提醒系数 
var furthest_distance_coefficient: float = 2.0 ## 最远距离系数


# 内部参数
var curve: Curve2D
@export var start_move: bool = false
var random_position: Vector2
var back: bool = false
var reset_hitbox: bool = false

func _ready() -> void:
	super()
	
func level_up(level) -> void:
	super(level)

enum State{
	WAIT,
	MOVE,
	ATTACK,
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)

	var distance_to_player = global_position.distance_to(player.global_position)
	var ratio = distance_to_player / (attributes["SEARCH_RAD"] * furthest_distance_coefficient)
	if ratio > reminder_threshold:
		distance_reminder.visible = true
		distance_reminder.scale = base_reminder_scale + Vector2(ratio - reminder_threshold, ratio - reminder_threshold)
	else:
		distance_reminder.visible = false

	if reset_hitbox:
		reset_hitbox = false
		hit_box.monitoring = true
		return

	match state:
		State.WAIT:
			do_tick_wait(delta)
			
			sync_direction.rpc(-PI/2, deg_to_rad(attributes["ROT_SPD"]) * delta)
			sync_slot_position.rpc()
			
		State.MOVE:
			do_tick_move(delta)
			
			if start_move:
				if not back:
					if not target:
						target = get_nearest_enemy(false)
					sync_position.rpc(target.global_position + random_position)
				else:
					sync_slot_position.rpc()
			else:
				if not back:
					sync_slot_position.rpc()
				else:
					sync_direction.rpc(-PI/2, deg_to_rad(attributes["ROT_SPD"]) * delta)
					
		State.ATTACK:
			do_tick_attack(delta)
			
			target_pos = target.global_position + target_dir * thrust_distance / 2
			var distance = global_position.distance_to(target_pos)
			var thrust_speed = lerpf(thrust_min_speed, thrust_max_speed, distance / thrust_distance)
			# sync_position.rpc(target_pos, weapon_stats.attributes[WeaponAttrManager.Attr.FLY_SPD] * delta)
			sync_position.rpc(target_pos, thrust_speed * delta)
			graphics.look_at(target_pos)
			if global_position.distance_squared_to(target_pos) <= pow(3, 2):
				target_dir = (target.global_position - global_position).normalized()
				hit_box.monitoring = false
				reset_hitbox = true
				

func get_next_state(state: State) -> int:
	if global_position.distance_squared_to(player.global_position) > pow(attributes["SEARCH_RAD"] * furthest_distance_coefficient, 2):
		back = true
		return StateMachine.KEEP_CURRENT if state == State.MOVE else State.MOVE
		
	match state:
		State.WAIT:
			target = get_nearest_enemy(false)
			if target and cooling_complete():
				back = false
				return State.MOVE
		State.MOVE:
			if not animation_player.is_playing():
				if not back:
					return State.ATTACK
				else:
					return State.WAIT
		State.ATTACK:
			if not target or target.is_dead:
				back = true
				return State.MOVE

	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:	
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match to:
		State.WAIT:
			do_enter_wait()
			
			start_move = false
			recovery_cooldown()
		State.MOVE:
			do_enter_move()
			
			if not back:
				random_position = get_random_position_on_circle(thrust_distance / 2)
			animation_player.play("move")
		State.ATTACK:
			do_enter_attack()
			
			start_move = false
			hit_box.monitoring = true
			target_dir = (target.global_position - global_position).normalized()
			

@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	$AnimationPlayer.play(animation_name)

	
func do_tick(delta: float) -> void:
	pass
	
func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_move(delta: float) -> void:
	pass
	
func do_tick_attack(delta: float) -> void:
	pass
	
func do_enter_wait() -> void:
	pass
	
func do_enter_move() -> void:
	pass
	
func do_enter_attack() -> void:
	pass
