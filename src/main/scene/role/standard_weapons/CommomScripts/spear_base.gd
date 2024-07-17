class_name SpearBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var base_charge_distance: float = 50  # 蓄力点距离
var base_charge_max_speed: float = 300
var base_attack_max_speed: float = 1500
var base_recall_max_speed: float = 1000
var base_recall_init_speed: float = 100
var base_recall_acceleration: float = 600
var thrust_distance_multiplier: float = 1.5
var recall_damage_reduce_ratio: float = 0.8


@export var charge_speed_curve: Curve
@export var attack_speed_curve: Curve

var charge_distance: float
var charge_max_speed: float
var attack_max_speed: float
var recall_max_speed: float
var recall_init_speed: float
var recall_acceleration: float

var recall_speed: float = 0.0

var curve: Curve2D
var curve_start_point: Vector2
var curve_charge_point: Vector2
var curve_end_point: Vector2
var curve_enemy_point: Vector2

var curve_offset_max1: float
var curve_offset_max2: float
var curve_speed: float = 0.0
var curve_offset: float = 0.0

var thrust_distance: float

var init_knockback: float

func _ready() -> void:
	super()
	
	recalculate_attribute.connect(_on_recalculate_attribute)
	update_speed(attributes["ATK_CD"])
	
func _on_ready() -> void:
	super()
	
	# 必须在 ready 之后的 _on_ready 中计算
	thrust_distance = search_collision_shape_2d.shape.radius * thrust_distance_multiplier
	
func level_up(level: int) -> void:
	super(level)
	

enum State {
	WAIT,
	CHARGE,
	ATTACK,
	RECALL,
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	match state:
		State.WAIT:
			do_tick_wait(delta)
			
			sync_slot_position.rpc()
			sync_direction.rpc(-PI/2, deg_to_rad(attributes["ROT_SPD"]) * delta)
			
		State.CHARGE:
			do_tick_charge(delta)
			
			move_by_curve(delta, 0)
			
		State.ATTACK:
			do_tick_attack(delta)
			
			move_by_curve(delta, 1)
			
		State.RECALL:
			do_tick_recall(delta)
			
			recall_speed = clampf(recall_speed + recall_acceleration * delta, 0, recall_max_speed)
			sync_slot_position.rpc(recall_speed * delta)
			
			towards_target(get_slot_target_position(), deg_to_rad(attributes["ROT_SPD"] * 2) * delta)

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
				return State.RECALL
				
		State.RECALL:
			if global_position.distance_squared_to(slot.global_position) <  pow(10, 2):
				return State.WAIT
			
	return StateMachine.KEEP_CURRENT
	

func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match from:
		State.WAIT:
			pass
				
		State.CHARGE:
			pass
				
		State.ATTACK:
			pass
				
		State.RECALL:
			recovery_cooldown()
			wam.update_attributes.emit(EffectScope.SELF, "KNOCKBACK", self, AttrType.FIXED, init_knockback)
			wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, recall_damage_reduce_ratio)
			wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, recall_damage_reduce_ratio)
	
	match to:
		State.WAIT:
			do_enter_wait()
			
			hit_box.monitoring = false
			
		State.CHARGE:
			do_enter_charge()
			
			curve_offset = 0.0
			
		State.ATTACK:
			do_enter_attack()
			
			hit_box.monitoring = true
			curve_offset = 0.0
			
		State.RECALL:
			do_enter_recall()
			
			recall_speed = recall_init_speed
			init_knockback = attributes["KNOCKBACK"]
			wam.update_attributes.emit(EffectScope.SELF, "KNOCKBACK", self, AttrType.FIXED, -init_knockback)
			wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, -recall_damage_reduce_ratio)
			wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, -recall_damage_reduce_ratio)
			
func move_by_curve(delta: float, stage: int) -> void:
	match stage:
		0:
			curve_speed = charge_speed_curve.sample_baked(curve_offset/curve_offset_max1) * charge_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max1)
			
		1:
			curve_speed = attack_speed_curve.sample_baked(curve_offset/curve_offset_max2) * attack_max_speed
			curve_offset = clampf(curve_offset + curve_speed * delta, 0, curve_offset_max2)
			
	var next_point = curve.sample_baked(curve_offset)
	sync_position.rpc(next_point)
	
	sync_direction.rpc(target_dir.angle())
	
	
			
func update_slash_curve(_target, info: bool = false) -> void:
	var result = create_slash_curve(global_position, _target.global_position, charge_distance)
	curve = result["curve"]
	
	curve_start_point = global_position
	curve_charge_point = result["charge_point"]
	curve_end_point = result["end_point"]
	curve_enemy_point = _target.global_position
	
	curve_offset_max1 = curve.get_closest_offset(curve_charge_point)
	curve_offset_max2 = curve.get_closest_offset(curve_end_point)
	
	target_dir = (curve_end_point - global_position).normalized()
	
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
	var angle = -150 if direction.x > 0 else 150
		
	# 旋转 150 度
	var rotated_direction = direction.rotated(deg_to_rad(angle)).normalized() * distance
	
	# 计算蓄力位置
	var charge_position = start_pos + rotated_direction
	return charge_position

func calculate_slash_end_position(charge_point: Vector2, enemy_pos: Vector2) -> Vector2:
	# 从蓄力位置到敌人位置的向量
	var to_enemy_vector = (enemy_pos - charge_point).normalized()
	
	thrust_distance = search_collision_shape_2d.shape.radius * thrust_distance_multiplier
	
	var end_point = charge_point + to_enemy_vector * thrust_distance
	
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

func do_tick_wait(delta: float) -> void:
	pass

func do_tick_charge(delta: float) -> void:
	pass

func do_tick_attack(delta: float) -> void:
	pass

func do_tick_recall(delta: float) -> void:
	pass

func do_enter_wait() -> void:
	pass

func do_enter_charge() -> void:
	pass

func do_enter_attack() -> void:
	pass

func do_enter_recall() -> void:
	pass

func update_speed(value: float) -> void:
	var ratio: float = base_attributes["ATK_CD"] / value
	
	# 这个不能变，否则会很鬼畜
	charge_distance = base_charge_distance
	
	charge_max_speed = base_charge_max_speed * ratio
	attack_max_speed = base_attack_max_speed * ratio
	recall_max_speed = base_recall_max_speed * ratio
	recall_init_speed = base_recall_init_speed * ratio
	recall_acceleration = base_recall_acceleration * ratio

func _on_global_attribute_change() -> void:
	super()
	
	thrust_distance_multiplier *= (1 + GlobalVars.spear_thrust_distance_gain_percentage)
	recall_damage_reduce_ratio *= (1 - GlobalVars.spear_recall_damage_reduce_gain_percentage)

func _on_recalculate_attribute(attr: String, value: float) -> void:
	match attr:
		"ATK_CD":
			update_speed(value)
