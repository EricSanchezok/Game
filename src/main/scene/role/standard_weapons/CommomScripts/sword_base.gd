class_name SwordBase
extends WeaponBase

var can_update_speed: bool = true

var base_charge_max_speed: float = 300
var base_attack_max_speed: float = 2000



var charge_distance: float = 60  # 蓄力点距离
var control_distance: float = 70  # 控制点距离
var charge_max_speed: float
var attack_max_speed: float
@export var charge_speed_curve: Curve
@export var attack_speed_curve: Curve
@export var back_speed_curve: Curve

var curve: Curve2D
var curve_start_point: Vector2
var curve_charge_point: Vector2
var curve_enemy_point: Vector2
var curve_offset_max1: float
var curve_offset_max2: float
var curve_offset_max3: float
var curve_speed: float = 0.0
var curve_offset: float = 0.0

enum State {
	WAIT,
	CHARGE,
	ATTACK,
	BACK
}

func _ready() -> void:
	super()
	recalculate_attribute.connect(_on_recalculate_attribute)
	update_speed(attributes["ATK_CD"])
	
func level_up(level) -> void:
	super(level)
	
func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)

	do_tick(delta)
	
	match state:
		State.WAIT:
			do_tick_wait(delta)

			sync_direction.rpc(-PI/2)
			sync_slot_position.rpc()
			
		State.CHARGE:
			do_tick_charge(delta)

			move_by_curve(delta, 0)

		State.ATTACK:
			do_tick_attack(delta)

			move_by_curve(delta, 1)

		State.BACK:
			do_tick_back(delta)

			move_by_curve(delta, 2)

func get_next_state(state: State) -> int:
	match state:
		State.WAIT:
			target = get_nearest_enemy()
			if target and cooling_complete():
				update_slash_curve(target, false)
				return State.CHARGE
				
		State.CHARGE:
			if curve_offset >= curve_offset_max1:
				return State.ATTACK
				
		State.ATTACK:
			if curve_offset >= curve_offset_max2:
				return State.BACK
				
		State.BACK:
			if curve_offset >= curve_offset_max3:
				return State.WAIT
				
	return StateMachine.KEEP_CURRENT

func transition_state(from: State, to: State) -> void:
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match to:
		State.WAIT:
			do_enter_wait()
			
			recovery_cooldown()
			hit_box.monitoring = false
			
		State.CHARGE:
			do_enter_charge()
			
			curve_offset = 0.0
			
		State.ATTACK:
			do_enter_attack()
			
			hit_box.monitoring = true
			#curve_offset = 0.0

		State.BACK:
			do_enter_back()
			
			#curve_offset = 0.0
			
func move_by_curve(delta: float, stage: int) -> void:
	match stage:
		0:
			curve_speed = charge_speed_curve.sample_baked(curve_offset/curve_offset_max1) * charge_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max1)
		1:
			curve_speed = attack_speed_curve.sample_baked(curve_offset/curve_offset_max2) * attack_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max2)
		2:
			curve_speed = back_speed_curve.sample_baked(curve_offset/curve_offset_max3) * attack_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max3)
			
	var next_point = curve.sample_baked(curve_offset)
	sync_position.rpc(next_point)
	
	var next_angle = get_curve_rotation(next_point)
	sync_direction.rpc(next_angle)
	
func update_slash_curve(_target, info: bool = false) -> void:
	var result = create_slash_curve(global_position, _target.global_position, charge_distance, control_distance)
	curve = result["curve"]
	curve_start_point = global_position
	curve_charge_point = result["charge_point"]
	curve_enemy_point = _target.global_position
	curve_offset_max1 = curve.get_closest_offset(curve_charge_point)
	curve_offset_max2 = curve.get_closest_offset(curve_enemy_point)
	curve_offset_max3 = (curve.get_baked_length() - curve_offset_max2) / 1.5 + curve_offset_max2
	if info:
		visualize_curve(curve)
	
func get_curve_rotation(point: Vector2) -> float:
	var to_start_vector = curve_start_point - point
	var tangent = Vector2(to_start_vector.y, -to_start_vector.x).normalized()
	tangent = tangent.rotated(-PI/2)
	return tangent.angle()
	
func create_slash_curve(start_pos: Vector2, enemy_pos: Vector2, charge_distance: float, control_distance: float) -> Dictionary:
	var curve = Curve2D.new()

	# 添加初始位置、敌人位置和结束位置到曲线
	curve.add_point(start_pos)
	
	var charge_point = calculate_slash_charge_position(start_pos, enemy_pos, charge_distance)
	
	curve.add_point(charge_point)
	
	# 计算敌人位置的控制点
	var control_points = calculate_slash_control_points(start_pos, enemy_pos, control_distance)
	curve.add_point(enemy_pos, control_points[0], control_points[1])
	
	curve.add_point(start_pos)  # 返回初始位置作为结束位置
	
	var result = {
		"curve": curve,
		"charge_point": charge_point
	}
	
	return result
	
func calculate_slash_charge_position(start_pos: Vector2, enemy_pos: Vector2, distance: float) -> Vector2:
	# 计算从起点到敌人的向量
	var direction = enemy_pos - start_pos
	
	# 检查敌人是否在左侧或右侧
	# 通过计算向量的角度变化
	var angle = -90 if direction.x > 0 else 90
		
	# 旋转90度
	var rotated_direction = direction.rotated(deg_to_rad(angle)).normalized() * distance
	
	# 计算蓄力位置
	var charge_position = start_pos + rotated_direction
	return charge_position

func calculate_slash_control_points(start_pos: Vector2, enemy_pos: Vector2, distance: float) -> Array:
	# 从敌人到初始位置的向量
	var to_start_vector = start_pos - enemy_pos
	
	# 计算该向量的垂直方向（正切方向）
	var tangent = Vector2(to_start_vector.y, -to_start_vector.x).normalized() * distance
	
	# 使用叉积确定敌人是否在左侧或右侧
	var cross_product = to_start_vector.cross(Vector2(1, 0))
	var in_control = -tangent
	var out_control = tangent 

	# 如果敌人在左侧，保持默认，如果在右侧，交换
	if to_start_vector.x > 0:  # 敌人在左侧
		return [out_control, in_control * 2.0]
	else:  # 敌人在右侧
		return [in_control, out_control * 2.0]

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
	

func do_tick(delta: float) -> void:
	pass

func do_tick_wait(delta: float) -> void:
	pass

func do_tick_charge(delta: float) -> void:
	pass

func do_tick_attack(delta: float) -> void:
	pass

func do_tick_back(delta: float) -> void:
	pass
			
func do_enter_wait() -> void:
	pass
	
func do_enter_charge() -> void:
	pass
	
func do_enter_attack() -> void:
	pass
	
func do_enter_back() -> void:
	pass
	
func update_speed(value: float) -> void:
	var ratio: float = base_attributes["ATK_CD"] / value
	
	if can_update_speed:
		charge_max_speed = base_charge_max_speed * ratio
		attack_max_speed = base_attack_max_speed * ratio
	else:
		charge_max_speed = base_charge_max_speed
		attack_max_speed = base_attack_max_speed

func _on_recalculate_attribute(attr: String, value: float) -> void:
	match attr:
		"ATK_CD":
			update_speed(value)
