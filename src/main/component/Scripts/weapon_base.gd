class_name WeaponBase
extends CharacterBody2D

## 闪电链特效
const LIGHTING_CHAIN = preload("res://src/main/scene/role/effect/LightingChainV2/lighting_chain.tscn")

@onready var center_marker_2d: Marker2D = $Graphics/CenterMarker2D ## 中心标记，通常会将其对齐到 slot 的位置
@onready var graphics: Node2D = $Graphics ## 武器的图形节点，一般旋转这个节点来改变武器的方向
@onready var hit_box: HitBox = $Graphics/HitBox ## 攻击盒
@onready var hurt_box: HurtBox = $Graphics/HurtBox ## 受击盒
@onready var reload_progress_bar: Marker2D = $ReloadProgressBar ## 冷却进度条
@onready var search_box: Area2D = $Graphics/SearchBox ## 搜索盒
@onready var search_collision_shape_2d: CollisionShape2D = $Graphics/SearchBox/CollisionShape2D ## 搜索盒的碰撞形状
@onready var shoot_marker_2d: Marker2D = $Graphics/ShootMarker2D ## 射击标记，通常射击类武器会在这个位置生成子弹
@onready var sprite_2d: Sprite2D = $Graphics/Sprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var timer_effect: Timer = $TimerEffect ## 效果计时器
@onready var weapon_icon: Sprite2D = $Graphics/Sprite2D ## 武器图标节点

## 当前属性加成影响到的武器范围
enum EffectScope {
	GLOBAL, SELF,
	FIRE, FROST, LIGHTING, EARTH, TOXIN, NATURE, DIVINITY, DEMON,  # Elements
	SWORD, SHIELD, AXE, SPEAR, DAGGER, BOW, STAFF, SCROLL, FIREARM, STATION, BOOK, BOOMERANG,  # Types
}

enum AttrType {
	FIXED, MULT
}

# 武器生成时传递的参数
var player_id: int ## 当前武器对应的玩家的id [color=red]（必须在生成时传递）[/color]
var weapon_id: int ## 武器类型的唯一性标识，可以用于判断两个武器是否是同一类 [color=red]（必须在生成时传递）[/color]
var slot_id: int ## 当前武器对应的槽位的id [color=red]（必须在生成时传递）[/color]

# 根据武器生成时传递的参数自动补齐的参数
var player: PlayerBase ## 当前武器对应的玩家，会在 _ready 函数中自动获取
var slot: Marker2D ## 当前武器对应的槽位，会在 _ready 函数中自动获取
var wam: WeaponAttributeManager

# 武器属性的定义
var traits = [] ## 当前武器的特质
var base_attributes = {}  ## 基础属性
var attributes_source = {}  ## 属性来源
var attributes = {} ## 当前属性

var stop_bullets: bool = false ## 能否击落子弹，注意：子弹被挡掉的逻辑是 子弹的 hurtbox 受到了 武器的 hitbox 的攻击

var weapon_level: int = 1: ## 武器等级
	set(v):
		weapon_level = v
		if not is_node_ready(): await ready
		match weapon_level:
			2:
				weapon_icon.material.set_shader_parameter("line_color", Color.BLUE)
				level_up(2)
			3:
				weapon_icon.material.set_shader_parameter("line_color", Color.RED)
				level_up(3)

				player.max_level_weapons.append({
					"weapon_id": weapon_id,
					"weapon_instance": self
				})

var enemies: Array = [] ## 搜索范围内的敌人数组
var target: EnemyBase  ## 当前的目标敌人
var target_pos: Vector2  ## 当前的目标位置
var target_dir: Vector2  ## 当前的目标方向
var hit_enemy: EnemyBase ## 当前 hitbox 击中的敌人
var hit_bullet: EnemyProjectileBase ## 当前 hitbox 击中的子弹

var attack_cooldown_time: float:
	set(v):
		attack_cooldown_time = clampf(v, 0, attributes["ATK_CD"])

var self_kill_count: int = 0 ## 击杀数
var self_damage_count: float = 0 ## 造成的伤害数

var is_lock: bool = false: ## 是否锁定武器，如果为 true 则武器将会锁定 state_machine，不会执行任何逻辑
	set(v):
		is_lock = v
		if not is_node_ready(): await ready
		state_machine.is_lock = v
		
@export var shoot_flag: bool = false: ## 发射投射物的标志，设置为 [param true] 时，会触发 shoot 函数，该函数可在武器脚本中自定义，shoot_flag 不用手动置为 false
	set(v):
		if not is_inside_tree():
			return
		if v:
			shoot()
			
signal freeze_success(enemy: EnemyBase) ## 成功冻结敌人
signal critical_success(enemy: EnemyBase) ## 成功暴击
signal damage_success(enemy: EnemyBase, amount: float) ## 成功造成伤害
signal kill_success(enemy: EnemyBase) ## 自己（当前武器）成功击杀敌人
signal deregistered(weapon: WeaponBase) ## 武器被注销
signal recalculate_attribute(attr: String, value: float) ## 某个属性被重新计算了

func _ready() -> void:
	# 补全基础数据
	player = Tools.get_player(player_id)
	slot = player.get_weapon_slot(slot_id)
	wam = player.wam
	
	search_collision_shape_2d.shape = CircleShape2D.new()
	
	if not player.is_node_ready(): await player.ready
	
	wam.update_attributes.connect(_on_update_attributes)

	# 初始化属性相关
	traits = WeaponsManager.get_traits(weapon_id)
	base_attributes = wam.get_base_attributes(weapon_id)
	for key in base_attributes.keys():
		attributes[key] = base_attributes[key]
		attributes_source[key] = {}
		recalculate(key)
	
	if WeaponsManager.is_weapon_unique(player_id, self):
		for _trait in traits:
			player.update_traits_count(_trait, 1)
			
	GlobalVars.global_attribute_changed.connect(_on_global_attribute_change)
	_on_global_attribute_change()

	player.register_weapon.connect(_on_player_register_weapon)
			
	if traits.has("STATION"):
		global_position = Tools.get_random_station_position()
	else:
		global_position = slot.global_position
		
	sprite_2d.use_parent_material = false
		
	ready.connect(_on_ready)
	deregistered.connect(_on_deregistered)
	
func _on_ready() -> void:
	attack_cooldown_time = attributes["ATK_CD"]
		
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 功能函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
## [color=yellow]基类中每帧需要调用的函数，请务必在 tick_physics 函数的开始每帧调用
func base_tick(delta: float) -> void:
	attack_cooldown_time -= delta
	reload_progress_bar.value = (attributes["ATK_CD"] - attack_cooldown_time) / attributes["ATK_CD"]

## 武器的升级函数，所有武器调用 level_up 时候都会调用这个函数，需要在子类中 super(level_up) 来调用这个函数[br]
## [br]
## [param level: int] 当前的等级[br]
func level_up(level: int) -> void: # 升级
	pass

func is_in_scope(scope: EffectScope, source: Variant) -> bool:
	match scope:
		EffectScope.GLOBAL:
			return true
		EffectScope.SELF:
			if source == self:
				return true
		_:
			if EffectScope.keys()[scope] in traits:
				return true
	return false
	
func shoot() -> void:
	pass
	
func recovery_cooldown() -> void:
	attack_cooldown_time = attributes["ATK_CD"]
	
func cooling_complete() -> bool:
	return attack_cooldown_time <= 0

## 返回两个武器是否相等[br]
## [br]
## [param other: WeaponBase] 另一个武器[br]
func equals(other: WeaponBase) -> bool:
	#print(weapon_id, " ", other.weapon_id)
	return weapon_id == other.weapon_id

## 返回当前武器的搜索范围中是否有敌人[br]
func has_enemy() -> bool:
	return enemies.size() > 0

## 返回当前武器是否在自身 slot 的附近[br]
func near_slot() -> bool:
	if global_position.distance_squared_to(get_slot_target_position()) < pow(5, 2):
		return true
	return false

## 返回是否瞄准成功，需要在这之前更新 target_dir[br]
func aim_success() -> bool:
	return Tools.are_angles_close(graphics.rotation, target_dir.angle())

## 返回当前武器自身 slot 的位置，由于是将center_marker_2d的位置对齐 slot，因此写了这个函数
func get_slot_target_position() -> Vector2:
	var target_position = slot.global_position
	target_position -= center_marker_2d.position.rotated($Graphics.global_rotation)
	
	return target_position

## 返回搜索范围中最近的敌人，若没有则返回 null[br]
## [br]
## [param is_self: bool] 是否以自身为中心，默认以玩家为中心[br]
func get_nearest_enemy(is_self: bool = false) -> EnemyBase:
	var nearestEnemy: EnemyBase = null
	var nearestDistance: float = INF
	var self_position = global_position if is_self else player.global_position
	for _enemy in enemies:
		var distance = _enemy.global_position.distance_squared_to(self_position)
		if distance < nearestDistance and not _enemy.is_dead:
			nearestEnemy = _enemy
			nearestDistance = distance
	return nearestEnemy

## 返回搜索范围中随机的敌人，若没有则返回 null[br]
func get_random_enemy() -> CharacterBody2D:
	if enemies.size() > 0:
		return enemies.pick_random()
	else:
		return null

## 返回基于基准方向和给定的角度范围中的随机方向[br]
## [br]
## [param base_direction: Vector2] 基准方向[br]
## [param angle_range: float] 角度范围[br]
func get_random_direction(base_direction: Vector2, angle_range: float) -> Vector2:
	var base_angle = base_direction.angle()
	
	var half_angle_range = angle_range * 0.5
	var random_angle = randf_range(-half_angle_range, half_angle_range)
	
	var new_angle = base_angle + deg_to_rad(random_angle)

	return Vector2(cos(new_angle), sin(new_angle))

## 返回给定半径的圆上的随机位置，目前为 DaggerBase 中的特需函数[br]
## [br]
## [param radius: float] 半径[br]
func get_random_position_on_circle(radius: float) -> Vector2:
	var angle = randf_range(0, 360)
	return Vector2(cos(angle), sin(angle)) * radius

## [color=red]rpc 函数 [/color][br]
## 将自身位置同步到 slot 位置[br]
## [br]
## [param displacement: float] 位移量，若为 0 则直接设置位置[br]
@rpc("authority", "call_local")
func sync_slot_position(displacement: float=0.0) -> void:
	var target_position = get_slot_target_position()
	if displacement == 0.0:
		global_position = target_position
	else:
		global_position = global_position.move_toward(target_position, displacement)

## [color=red]rpc 函数 [/color][br]
## 将自身位置同步到指定位置[br]
## [br]
## [param target_position: Vector2] 目标位置[br]
## [param displacement: float] 位移量，若为 0 则直接设置位置[br]
@rpc("authority", "call_local")
func sync_position(target_position: Vector2, displacement: float=0.0) -> void:
	if displacement == 0.0:
		global_position = target_position
	else:
		global_position = global_position.move_toward(target_position, displacement)

## [color=red]rpc 函数 [/color][br]
## 将自身方向同步到指定方向[br]
## [br]
## [param target_rotation: float] 目标角度[br]
## [param angular_displacement: float] 角度变化量，若为 0 则直接设置角度[br]
@rpc("authority", "call_local")
func sync_direction(target_rotation: float, angular_displacement: float=0.0) -> void:
	if angular_displacement == 0.0:
		$Graphics.global_rotation = target_rotation # 若角度变化量为 0，则直接设置角度，立刻同步
	else:
		$Graphics.global_rotation = lerp_angle($Graphics.global_rotation, target_rotation, angular_displacement) # 若角度变化量不为 0，则使用插值函数，平滑同步

## [color=red]rpc 函数 [/color][br]
## 朝向目标位置[br]
## [br]
## [param target_position: Vector2] 目标位置[br]
## [param angular_displacement: float] 角度变化量，若为 0 则直接设置角度[br]
@rpc("authority", "call_local")
func towards_target(target_position: Vector2, angular_displacement: float=0.0) -> void:
	var target_direction = target_position - position
	var target_rotation = target_direction.angle()
	sync_direction(target_rotation, angular_displacement)

## [BowBase] 特需函数，返回弓箭的子弹生成时的初始角度[br]
## [br]
## [param center_rotation: float] 中心角度，多数情况下是武器当前的角度[br]
## [param index: int] 当前子弹在所有子弹中的索引[br]
## [param max_index: int] 所有子弹的数量[br]
## [param max_count: int] 最大数量，默认为 7，基本上不需要修改[br]
## [param max_angle: float] 最大角度，默认为 120，基本上不需要修改[br]
func get_projectile_rotation(center_rotation: float, index: int, max_index: int, max_count: int = 7, max_angle: float = 120) -> float:
	if max_index <= max_count:
		if index % 2 == 0:
			return center_rotation + deg_to_rad(max_angle / (max_count - 1) * index / 2)
		else:
			return center_rotation - deg_to_rad(max_angle / (max_count - 1) * (index + 1) / 2)
	else:
		if index % 2 == 0:
			return center_rotation + deg_to_rad(max_angle / (max_index - 1) * index / 2)
		else:
			return center_rotation - deg_to_rad(max_angle / (max_index - 1) * (index + 1) / 2)

## 延迟调用 add_lighting_chain.rpc()
func deferred_add_lighting_chain() -> void:
	add_lighting_chain.rpc()
	
## [color=red]rpc 函数 [/color][br]
## 添加闪电链特效，闪电链的 current_enemy 为当前击中的敌人，因此需要在这之前更新 hit_enemy（默认_on_hit_box_hit函数中更新）[br]
@rpc("authority", "call_local")
func add_lighting_chain() -> void:
	var instance = LIGHTING_CHAIN.instantiate()
	instance.remaining_connections = attributes["LCH_COUNT"]
	instance.player = player
	instance.weapon = self
	instance.current_enemy = hit_enemy
	instance.damage_current = true
	instance.former_enemies = []

	Game.add_object(instance)

func recalculate(attr: String) -> void:
	if not attributes[attr] is float:
		return
	
	var fixed_total: float = 0.0
	var mult_total: float = 0.0
	for source in attributes_source[attr]:
		for type in attributes_source[attr][source]:
			match type:
				AttrType.FIXED:
					fixed_total += attributes_source[attr][source][type]
				AttrType.MULT:
					mult_total += attributes_source[attr][source][type]
	# 总计算公式
	match attr:
		"ATK_CD":
			attributes[attr] = (base_attributes[attr] + fixed_total) / (1 + mult_total)
		_:
			attributes[attr] = (base_attributes[attr] + fixed_total) * (1 + mult_total)
			
	var value = attributes[attr]
	
	# 应用效果
	match attr:
		"SEARCH_RAD":
			search_collision_shape_2d.shape.radius = value
				
		"EFF_DUR":
			timer_effect.wait_time = value if value != 0 else 999

		"WEAPON_SIZE":
			var target_scale = Vector2(1 + value, 1 + value)
			
			var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
			tween.tween_property(self, "scale", target_scale, 0.2)
			
	recalculate_attribute.emit(attr, value)
			
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 回调函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func _on_global_attribute_change() -> void:
	pass

func _on_player_register_weapon(_player_id: int, _weapon_id: int, _slot_id: int) -> void:
	pass

func _on_search_box_body_entered(enemy: EnemyBase) -> void:
	if enemy.is_in_group("enemy") and not enemies.has(enemy):
		enemies.append(enemy)
		if not enemy.enemy_die.is_connected(_on_enemy_die):
			enemy.enemy_die.connect(_on_enemy_die)
		
func _on_search_box_body_exited(enemy: EnemyBase) -> void:
	if enemy.is_in_group("enemy") and enemies.has(enemy):
		enemies.erase(enemy)
		if enemy.enemy_die.is_connected(_on_enemy_die):
			enemy.enemy_die.disconnect(_on_enemy_die)
		
func _on_enemy_die(dead_enemy: EnemyBase) -> void:
	if enemies.has(dead_enemy):
		enemies.erase(dead_enemy)

func _on_hit_box_hit(hurtbox: Variant) -> void:
	if hurtbox.owner is EnemyBase:
		hit_enemy = hurtbox.owner
	elif hurt_box.owner is EnemyProjectileBase:
		hit_bullet = hurtbox.owner
	
func _on_damage_success(enemy: EnemyBase, amount: float) -> void:
	self_damage_count += amount
	
func _on_kill_success(enemy: EnemyBase) -> void:
	self_kill_count += 1

func _on_deregistered(weapon: WeaponBase) -> void:
	if WeaponsManager.is_weapon_unique(player_id, self):
		for _trait in traits:
			player.update_traits_count(_trait, -1)

	queue_free()

func _on_update_attributes(scope: EffectScope, attr: String, source: Variant, type: AttrType, value: float) -> void:
	if not is_in_scope(scope, source) or not base_attributes.has(attr): 
		return
	
	if not attributes_source[attr].has(source):
		attributes_source[attr][source] = {}
		
	attributes_source[attr][source][type] = attributes_source[attr][source].get(type, 0) + value
	
	recalculate(attr)
