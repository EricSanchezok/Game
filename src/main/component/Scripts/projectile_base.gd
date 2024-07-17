class_name ProjectileBase
extends CharacterBody2D

const LIGHTING_CHAIN = preload("res://src/main/scene/role/effect/LightingChainV2/lighting_chain.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var destroy_timer: Timer = $DestroyTimer
@onready var graphics: Node2D = $Graphics
@onready var hit_box: HitBox = $Graphics/HitBox

@export var do_not_need_know_anything: bool = false ## 如果设置为 [param true]，则不会自动获取 player 和 weapon 以及任何的参数，需要手动传递
@export var manual_start: bool = false ## 如果设置为 [param true]，则需要手动开启投射物
@export var tracking: bool = false ## 是否追踪目标
@export var is_dir_mode: bool = false ## 是否使用方向模式，如果为 [param true]，则会使用 init_rotation 作为初始方向
@export var bezier: bool = false ## 是否使用贝塞尔曲线，只在 tracking 为 [param true] 时有效
@export var bezier_param: float = 1.0 ## 贝塞尔曲线参数，只在 tracking 为 [param true] 且 bezier 为 [param true] 时有效
@export var in_front: bool = false ## 是否追踪目标朝玩家一定距离的位置
@export var in_front_dis: int = 5 ## 追踪目标朝玩家一定距离的位置的距离
@export var stop_bullets: bool = false ## 能否拦下子弹
@export var acceleration: float = 0.0 ## 加速度
@export var deceleration: float = 0.0 ## 减速度（还不完善）
@export var projectile_rand: bool = true
@export var projectile_rand_range = Vector2(0.8, 1.2)

# 投射物生成时传递的参数
var player_id: int ## 生成投射物的玩家id，需要在生成时传递
var slot_id: int ## 生成投射物的武器槽位id， 需要在生成时传递
var init_rotation: float ## 生成投射物的初始角度，需要在生成时传递
var init_position: Vector2 ## 生成投射物的初始位置，需要在生成时传递
var target: EnemyBase ## tracking 为 [param true] 时，必须传递 target 参数
var target_pos: Vector2 ## tracking 为 [param false] 且 is_dir_mode 为 [param false] 时，必须传递 target_pos

var player: PlayerBase ## 属于的玩家
var weapon: WeaponBase ## 属于的武器
var target_dir: Vector2 ## is_dir_mode 为 [param true] 时，会自动将 init_rotation 作为 target_dir
var hit_enemy: EnemyBase ## 当 hitbox 触发时，会将触发的敌人传递给这个变量
var attributes: Dictionary

var start_flag: bool = false: ## 用于手动开启投射物，置为 [param true] 时会触发_on_start_flag_switch_on
	set(v):
		start_flag = v
		if start_flag:
			hit_box.monitoring = true
			_on_start_flag_switch_on()

var reached: bool = false: ## 当到达 target 或 target_pos 或在中途被敌人拦下且没有穿透时，会置为 [param true]，同时会触发 reach_target 信号
	set(v):
		reached = v
		if reached:
			stop_moveing = true
			reach_target.emit()

var stop_moveing: bool = false ## 内置运动参数，无需关注
var current_time: float = 0.0 ## 内置运动参数，无需关注

signal reach_target

func _ready() -> void:
	if not do_not_need_know_anything:
		player = Tools.get_player(player_id)
		weapon = Tools.get_weapon(player_id, slot_id)
		
		attributes = weapon.attributes.duplicate(true)
		
		Tools.apply_spawn_object_size_multiplier(self)
				
		graphics.rotation = init_rotation
		global_position = init_position

		target_dir = Vector2(cos(init_rotation), sin(init_rotation))
		
		if attributes["EFF_DUR"] != 0:
			destroy_timer.wait_time = attributes["EFF_DUR"]
		else:
			destroy_timer.wait_time = 999
			printerr(name, " 没有设置投射物的持续时间，默认设置为999！")
			
		destroy_timer.start()
	
	if manual_start:
		hit_box.monitoring = false
	
	if not ready.is_connected(_on_ready):
		ready.connect(_on_ready)
	if not reach_target.is_connected(_on_reach_target):
		reach_target.connect(_on_reach_target)

func _on_ready() -> void:
	if projectile_rand:
		projectile_randomize()
	
func _process(delta: float) -> void:
	if manual_start:
		if not start_flag:
			return
			
	do_tick(delta)
	
	if stop_moveing:
		return
	
	attributes["FLY_SPD"] = attributes["FLY_SPD"] + acceleration * delta - deceleration * delta
	
	if attributes["FLY_SPD"] <= 0:
		stop_moveing = true
		reached = true
		return
	
	if tracking:
		if is_instance_valid(target):
			if not target.is_dead:
				if not in_front:
					target_pos = target.global_position
				else:
					var dir_to_player = (player.global_position - target.global_position).normalized()
					target_pos = target.global_position + in_front_dis * dir_to_player
		if bezier:
			current_time += delta
			var distance = global_position.distance_to(target_pos)
			var total_time = distance / attributes["FLY_SPD"]
			var t = min(current_time/total_time, 1)
			var start_control_point = global_position + Vector2(cos(graphics.rotation), sin(graphics.rotation)) * attributes["FLY_SPD"] * bezier_param
			var next_point = global_position.bezier_interpolate(start_control_point, target_pos, target_pos, t)
			
			sync_dir_and_pos.rpc(next_point, delta)
		else:
			sync_dir_and_pos.rpc(target_pos, delta)

	else:
		if not is_dir_mode:
			sync_dir_and_pos.rpc(target_pos, delta)
		else:
			sync_dir_and_pos.rpc(global_position + target_dir * attributes["FLY_SPD"], delta)
	
	do_tick_moving(delta)
	
	if global_position.distance_squared_to(target_pos) < pow(3, 2) and not reached:
		reached = true

@rpc("authority", "call_local")
func sync_dir_and_pos(next_pos: Vector2, delta: float) -> void:
	graphics.look_at(next_pos)
	global_position = global_position.move_toward(next_pos, attributes["FLY_SPD"] * delta)
	
@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)
	
@rpc("authority", "call_local")
func sync_free() -> void:
	queue_free()
	
func do_tick(delta: float) -> void:
	pass
	
func do_tick_moving(delta: float) -> void:
	pass
	
func projectile_randomize() -> void:
	attributes["FLY_SPD"] = attributes["FLY_SPD"] * randf_range(projectile_rand_range.x, projectile_rand_range.y)
	
func deferred_add_lighting_chain() -> void:
	add_lighting_chain.rpc()
	
@rpc("authority", "call_local")
func add_lighting_chain() -> void:
	var instance = LIGHTING_CHAIN.instantiate()
	instance.remaining_connections = attributes["LCH_COUNT"]
	instance.player = player
	instance.weapon = weapon
	instance.current_enemy = hit_enemy
	instance.damage_current = true
	instance.former_enemies = []

	Game.add_object(instance)

func _on_hit_box_hit(hurtbox: Variant) -> void:
	if hurtbox.owner is EnemyBase:
		hit_enemy = hurtbox.owner
		
	if not Tools.is_success(attributes["PEN_RATE"]):
		if not reached:
			reached = true

func _on_reach_target() -> void:
	pass
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "finish":
		sync_free.rpc()
		
func _on_destroy_timer_timeout() -> void:
	reached = true

func _on_start_flag_switch_on() -> void:
	pass

