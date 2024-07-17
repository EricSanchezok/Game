class_name AxeBase
extends WeaponBase

@onready var area_pick_up: Area2D = $AreaPickUp
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var charge_distance: float = 50  # 蓄力点距离
@export var charge_max_speed: float = 200
@export var attack_max_speed: float = 1000
@export var charge_speed_curve: Curve
@export var attack_speed_curve: Curve

var curve: Curve2D

var curve_start_point: Vector2
var curve_charge_point: Vector2
var curve_end_point: Vector2
var curve_enemy_point: Vector2

var curve_offset_max1: float
var curve_offset_max2: float

var charge_rotation: float
var attack_rotation: float

var curve_speed: float = 0.0
var curve_offset: float = 0.0

var picked_up: bool = false:
	set(v):
		picked_up = v
		if picked_up:
			attack_cooldown_time = 0.0
var tween_anim: Tween

signal pick_all_axes

var next_enemies: Array = []

func _ready() -> void:
	super()
	
	for weapon in Tools.my_target_weapons("AXE"):
		weapon.connect("pick_all_axes", _on_pick_all_axes)
		
	area_pick_up.body_entered.connect(_on_area_pick_up_body_entered)
	
func level_up(level) -> void:
	super(level)

enum State {
	APPEAR,
	WAIT,
	CHARGE,
	ATTACK,
	LANDING,
	DISAPPEAR,
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)

	do_tick(delta)
		
	match state:
		State.APPEAR:
			do_tick_appear(delta)
			
			sync_direction.rpc(-PI/2)
			sync_slot_position.rpc()
			
		State.WAIT:
			do_tick_wait(delta)

			sync_slot_position.rpc()
			
		State.CHARGE:
			do_tick_charge(delta)

			move_by_curve(delta, 0)
			
		State.ATTACK:
			do_tick_attack(delta)

			move_by_curve(delta, 1)
			
		State.LANDING:
			do_tick_landing(delta)
			
		State.DISAPPEAR:
			do_tick_disappear(delta)

func get_next_state(state: State) -> int:
	match state:
		State.APPEAR:
			if tween_anim and not tween_anim.is_running():
				return State.WAIT
				
		State.WAIT:
			target = get_nearest_enemy()
			if target:
				update_slash_curve(target, false)
				return State.CHARGE
				
		State.CHARGE:
			if curve_offset >= curve_offset_max1:
				return State.ATTACK
				
		State.ATTACK:
			if curve_offset >= curve_offset_max2:
				return State.LANDING
				
		State.LANDING:
			if cooling_complete() or picked_up:
				return State.DISAPPEAR
				
		State.DISAPPEAR:
			if tween_anim and not tween_anim.is_running():
				return State.APPEAR
			
	return StateMachine.KEEP_CURRENT
	

func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match to:
		State.APPEAR:
			do_enter_appear()

			hit_box.monitoring = false
			tween_anim = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			tween_anim.parallel().tween_property(graphics, "scale", Vector2.ONE, 0.3).from(Vector2.ZERO)

		State.WAIT:
			do_enter_wait()
			
		State.CHARGE:
			do_enter_charge()

			picked_up = false
			curve_offset = 0.0
			
		State.ATTACK:
			do_enter_attack()

			hit_box.monitoring = true
			curve_offset = 0.0
			
		State.LANDING:
			do_enter_landing()

			recovery_cooldown()
			area_pick_up.monitoring = true
			hit_box.monitoring = false
			
		State.DISAPPEAR:
			do_enter_disappear()

			area_pick_up.monitoring = false
			picked_up = false
			
			tween_anim = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			tween_anim.parallel().tween_property(graphics, "scale", Vector2.ZERO, 0.3).from(Vector2.ONE)
			
func move_by_curve(delta: float, stage: int) -> void:
	match stage:
		0:
			curve_speed = charge_speed_curve.sample_baked(curve_offset/curve_offset_max1) * charge_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max1)
			
		1:
			curve_speed = attack_speed_curve.sample_baked(curve_offset/curve_offset_max2) * attack_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max2)
			var next_angle = lerp_angle(charge_rotation, attack_rotation, curve_offset/curve_offset_max2)
			sync_direction.rpc(next_angle)
			
	var next_point = curve.sample_baked(curve_offset)
	sync_position.rpc(next_point)
	
	match stage:
		0:
			var next_angle = get_curve_rotation(next_point, curve_start_point)
			sync_direction.rpc(next_angle)
		1:
			pass
	
func update_slash_curve(_target, info: bool = false) -> void:
	var result = create_slash_curve(global_position, _target.global_position, charge_distance)
	curve = result["curve"]
	
	curve_start_point = global_position
	curve_charge_point = result["charge_point"]
	curve_end_point = result["end_point"]
	curve_enemy_point = _target.global_position
	
	curve_offset_max1 = curve.get_closest_offset(curve_charge_point)
	curve_offset_max2 = curve.get_closest_offset(curve_end_point)
	
	
	charge_rotation = get_curve_rotation(curve_charge_point, curve_start_point)
	attack_rotation = get_curve_rotation(curve_end_point, curve_charge_point)
	
	if info:
		visualize_curve(curve)
		
func get_curve_rotation(current_point: Vector2, start_point: Vector2) -> float:
	var to_start_vector = current_point - start_point
	var angle = to_start_vector.angle()
	return angle
			
func create_slash_curve(start_pos: Vector2, enemy_pos: Vector2, charge_distance: float) -> Dictionary:
	var curve = Curve2D.new()

	# 添加初始位置、敌人位置和结束位置到曲线
	curve.add_point(start_pos)
	
	var charge_point = calculate_slash_charge_position(start_pos, enemy_pos, charge_distance)
	
	curve.add_point(charge_point)
	
	var end_point = calculate_slash_end_position(charge_point, enemy_pos)
	
	curve.add_point(end_point)
	
	var result = {
		"curve": curve,
		"charge_point": charge_point,
		"end_point": end_point
	}
	
	return result
	
func calculate_slash_charge_position(start_pos: Vector2, enemy_pos: Vector2, distance: float) -> Vector2:
	# 计算从起点到敌人的向量
	var direction = enemy_pos - start_pos
	
	# 检查敌人是否在左侧或右侧
	# 通过计算向量的角度变化
	var angle = -120 if direction.x > 0 else 120
		
	# 旋转 150 度
	var rotated_direction = direction.rotated(deg_to_rad(angle)).normalized() * distance
	
	# 计算蓄力位置
	var charge_position = start_pos + rotated_direction
	return charge_position

func calculate_slash_end_position(charge_point: Vector2, enemy_pos: Vector2) -> Vector2:
	# 从蓄力位置到敌人位置的向量
	var to_enemy_vector = (enemy_pos - charge_point).normalized()
	
	var radius = search_collision_shape_2d.shape.radius * 2
	
	var end_point = charge_point + to_enemy_vector * radius
	
	return end_point

# 可视化曲线
func visualize_curve(curve: Curve2D):
	#移除已存在的Line2D
	var lines = get_tree().get_nodes_in_group("visual_line")
	for child in lines:
		if is_instance_valid(child):
			remove_child(child)
			child.queue_free()  # 安全地删除对象
			
	var line = Line2D.new()
	line.width = 2
	line.default_color = Color(1, 1, 1)
	line.points = curve.get_baked_points()
	line.z_index = 50
	line.add_to_group("visual_line")
	get_tree().root.add_child(line)

@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)



func do_tick(delta: float) -> void:
	pass

func do_tick_appear(delta: float) -> void:
	pass

func do_tick_wait(delta: float) -> void:
	pass

func do_tick_charge(delta: float) -> void:
	pass

func do_tick_attack(delta: float) -> void:
	pass

func do_tick_landing(delta: float) -> void:
	pass

func do_tick_disappear(delta: float) -> void:
	pass

func do_enter_appear() -> void:
	pass

func do_enter_wait() -> void:
	pass

func do_enter_charge() -> void:
	pass

func do_enter_attack() -> void:
	pass

func do_enter_landing() -> void:
	pass

func do_enter_disappear() -> void:
	pass

	
func _on_pick_all_axes() -> void:
	picked_up = true

func _on_area_pick_up_body_entered(player: PlayerBase) -> void:
	if attributes["PICK_AXE"] >= 1:
		picked_up = true
		if attributes["PICK_AXE"] == 2:
			pick_all_axes.emit()

	
