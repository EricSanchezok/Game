class_name EnemyBase
extends CharacterBody2D

const DAMAGE_NUMBERS = preload("res://src/main/scene/ui/damage_number.tscn")

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 导入模块 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coin_generator: CoinGenerator = $CoinGenerator
@onready var damage_number_marker_2d: Marker2D = $Graphics/DamageNumberMarker2D
#@onready var enemy_stats: EnemyStats = $EnemyStats
@onready var graphics: Node2D = $Graphics
@onready var health_regeneration_timer: Timer = $Timers/HealthRegenerationTimer
@onready var shadow: Sprite2D = $Graphics/Shadow
@onready var sprite_2d: Sprite2D = $Graphics/Sprite2D
@onready var state_machine: StateMachine = $StateMachine
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var shoot_marker: Marker2D = $Graphics/ShootMarker

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 导入特效模块 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@onready var burn_gpu_particles_2d: GPUParticles2D = $Graphics/VFX/BurnGPUParticles2D
@onready var freeze_animated_sprite_2d: AnimatedSprite2D = $Graphics/VFX/FreezeAnimatedSprite2D
@onready var mini_explosion_animated_sprite_2d: AnimatedSprite2D = $Graphics/VFX/MiniExplosionAnimatedSprite2D
@onready var fragile_animated_sprite_2d: AnimatedSprite2D = $Graphics/VFX/FragileAnimatedSprite2D

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 常规变量定义 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
enum AttrType {
	FIXED, MULT
}

var base_attributes = { ## 基础属性
	"MAX_HP": 0.0,
	"HP": 0.0,
	"HP_REGEN": 0.0,
	"MOV_SPD": 0.0,
	"ACCEL": 0.0,
	"DMG": 0.0,
	"KNB_RES": 0.0,
	"SLOW_RES": 0.0,
	"FRZ_RES": 0.0
}
var attributes_source = {}  ## 属性来源
var attributes: Dictionary ## 当前属性

var enemy_type: String = "A"

enum Direction { ## 方向
	LEFT = -1, 	## 左
	RIGHT = +1,	## 右
}
var target: PlayerBase ## 准备攻击和追击的目标玩家
var pending_damages: Array[Damage] = [] ## 待结算伤害数组，由于怪物可能同时受到多种伤害，所以需要一个数组来存储
var attraction_sources: Array = [] ## 正在牵引敌人的牵引源数组
var progress: int ## 当前关卡的进度，怪物的一些数值会根据进度进行调整

@export var is_shade_like: bool = false ## 是否是基于 SHADE 的怪物，如果是，则会使用 SHADE 的动画资源
@export var enemy_rand: bool = true ## 是否随机化怪物，怪物随机化会经过调用 enemy_randomize 函数进行随机化，随机化的范围由 enemy_rand_range 定义，而且怪物的生命值、速度、动画速度等都会受到随机化的影响
@export var enemy_rand_range = Vector2(0.8, 1.2) ## 当 enemy_rand 为 [param true] 时，怪物的随机化范围
var rand_float: float ## 怪物随机化后会生成此随机浮点数，用于影响怪物的各项数值，并且可以传递给怪物生成的子弹，让子弹也受到随机化的影响
@export var coin_value: int = 1 ## 怪物死亡时掉落的单个金币的价值
@export var coin_count: int = 1 ## 怪物死亡时掉落的金币数量
@export var energy_value: float = 1.0 ## 怪物死亡时掉落的能量值

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 信号定义 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
signal enemy_die(enemy: EnemyBase)
signal recalculate_attribute(attr: String, value: float) ## 某个属性被重新计算了
signal update_attributes(attr: String, source: Variant, type: AttrType, value: float) ## 激发这个信号来更新玩家的参数

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 效果参数定义 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
enum Effect {
	SLOW,
	POISION,
	FREEZE,
	FRAGILE,
}
var effect_queue: Array
class effect:
	var value: float = 0.0
	var duration: float = 0.0
	var source_weapon: WeaponBase
	var other

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 状态变量 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@export var is_dead: bool = false: ## 是否死亡，会触发 enemy_die 信号，并且如果 is_freeze 为 [param true]，则会解除冻结
	set(v):
		if is_dead == v:
			return
		is_dead = v
		if is_dead:
			enemy_die.emit(self)
			if is_freeze:	is_freeze = false

@export var is_slow = false: ## 是否减速，若切换为 [param true]，则会调整颜色，若切换为 [param false]，则会恢复颜色
	set(v):
		if is_slow == v:
			return
		if Tools.switch_on(v, is_slow):
			sprite_2d.modulate = Color.hex(0x4dffff)
		elif Tools.switch_off(v, is_slow):
			sprite_2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
		is_slow = v
var _apply_slow: bool = false

@export var is_poision = false
		
@export var is_freeze = false: ## 是否冻结，如果在 is_freeze 为 [param true] 期间死亡，则会被置为 [param false]，并且会执行 enter_die 函数
	set(v):
		if is_freeze == v:
			return
		if Tools.switch_on(v, is_freeze):
			pause_animation.rpc()
			freeze_animated_sprite_2d.show()
			freeze_animated_sprite_2d.play("freeze")
			shadow.hide()
		elif Tools.switch_off(v, is_freeze):
			if not is_dead:
				replay_animation.rpc()
			else:
				enter_die()
			freeze_animated_sprite_2d.play("unfreeze")
			shadow.show()
		is_freeze = v
		
@export var is_fragile: bool = false:
	set(v):
		if is_fragile == v:
			return
		if Tools.switch_on(v, is_fragile):
			fragile_animated_sprite_2d.show()
			fragile_animated_sprite_2d.play("on")
		elif Tools.switch_off(v, is_fragile):
			fragile_animated_sprite_2d.play("off")
		is_fragile = v

@export var direction := Direction.RIGHT:
	set(v):
		direction = v
		if not is_node_ready():	await ready
		graphics.scale.x = direction

func _ready() -> void:
	for i in range(Effect.size()):
		effect_queue.append([])
		
	freeze_animated_sprite_2d.hide()
	fragile_animated_sprite_2d.hide()
	
	update_attributes.connect(_on_update_attributes)
		
	ready.connect(_on_ready)
	
func _on_ready() -> void:
	init_attributes()
	
	if enemy_rand:
		enemy_randomize()
		
	apply_enemy_texture()
		
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 功能函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

@rpc("authority", "call_local")
func pause_animation() -> void:
	animation_player.pause()

@rpc("authority", "call_local")
func replay_animation() -> void:
	animation_player.play()

func enter_appear() -> void:
	if not is_shade_like:
		update_animation.rpc("appear")
	else:
		update_animation.rpc("ShadeLike/appear")
		
func enter_run() -> void:
	if not is_shade_like:
		update_animation.rpc("run")
	else:
		update_animation.rpc("ShadeLike/run")
		
func enter_hurt() -> void:
	if not is_shade_like:
		update_animation.rpc("hurt")
	else:
		update_animation.rpc("ShadeLike/hurt")
	
func enter_die() -> void:
	if not is_dead: is_dead = true
	if not is_shade_like:
		update_animation.rpc("die")
	else:
		update_animation.rpc("ShadeLike/die")

func update_effects(delta: float) -> void:
	# >>>>>>>>>>>>>>>>>>>> 更新效果持续时间 >>>>>>>>>>>>>>>>>>>>
	for type_index in range(effect_queue.size()):
		for _effect in effect_queue[type_index]:
			_effect.duration -= delta
			if _effect.duration <= 0: 
				# 所有效果中的 单个效果 持续时间结束时的函数
				match type_index:
					Effect.SLOW:
						if _effect != effect_queue[Effect.SLOW][0]:
							continue
						update_attributes.emit("MOV_SPD", effect_queue[Effect.SLOW][0].source_weapon, AttrType.MULT, effect_queue[Effect.SLOW][0].value)
						#enemy_stats.movement_speed_multiplier += effect_queue[Effect.SLOW][0].value
						animation_player.speed_scale += effect_queue[Effect.SLOW][0].value
						_apply_slow = false
						
					Effect.POISION:
						pass
						
					Effect.FREEZE:
						pass
						
					Effect.FRAGILE:
						pass
						
				effect_queue[type_index].erase(_effect)

	if effect_queue[Effect.SLOW].size() <= 0:
		is_slow = false

	if effect_queue[Effect.POISION].size() <= 0:
		is_poision = false

	if effect_queue[Effect.FREEZE].size() <= 0:
		is_freeze = false
		
	if effect_queue[Effect.FRAGILE].size() <= 0:
		is_fragile = false

func apply_effects(delta: float) -> void:
	# >>>>>>>>>>>>>>>>>>>> 每一帧的结算效果 >>>>>>>>>>>>>>>>>>>>
	if is_slow:
		if not _apply_slow:
			update_attributes.emit("MOV_SPD", effect_queue[Effect.SLOW][0].source_weapon, AttrType.MULT, -effect_queue[Effect.SLOW][0].value)
			#enemy_stats.movement_speed_multiplier -= effect_queue[Effect.SLOW][0].value
			animation_player.speed_scale -= effect_queue[Effect.SLOW][0].value
			_apply_slow = true
	else:
		pass

	if is_poision:
		effect_queue[Effect.POISION][0].other += delta
		if effect_queue[Effect.POISION][0].other >= 1.0:  # 每秒应用一次中毒伤害
			var damage = Damage.new()
			damage.source_weapon = effect_queue[Effect.POISION][0].source_weapon
			damage.mag_amount = effect_queue[Effect.POISION][0].value
			pending_damages.append(damage)
			effect_queue[Effect.POISION][0].other -= 1.0  # 重置计时器
	else:
		pass

	if is_freeze:
		pass
	else:
		pass
		
	if is_fragile:
		pass
	else:
		pass


func apply_damages() -> void:
	# >>>>>>>>>>>>>>>>>>>> 结算伤害 >>>>>>>>>>>>>>>>>>>>
	var be_killed: bool = false
	var max_knockback_damage: Damage = Damage.new()
	for damage in pending_damages:
		update_attributes.emit("HP", damage.source_weapon, AttrType.FIXED, -damage.phy_amount + damage.mag_amount)
		#enemy_stats.current_health -= damage.phy_amount + damage.mag_amount
		
		# 触发吸血
		if damage.direct_object.attributes["LIFE_STEAL"] > 0.0:
			var life_steal_value = damage.direct_object.attributes["LIFE_STEAL"] * (damage.phy_amount + damage.mag_amount)
			damage.source_weapon.player.life_steal_success.emit(self, life_steal_value)
		
		# 触发致命伤害
		if attributes["HP"] <= 0 and not be_killed:
			damage.source_weapon.kill_success.emit(self)
			damage.source_weapon.player.kill_success.emit(self)
			be_killed = true
			
			StatisticalData.register_kill(damage.source_weapon.player_id, damage.source_weapon.weapon_id)
		
		# 选择同一帧中击退最大的值
		if damage.knockback > max_knockback_damage.knockback:
			max_knockback_damage = damage
		
		# 创建伤害数字
		create_damage_numbers(damage)
		
		# 触发伤害成功
		damage.source_weapon.damage_success.emit(self, damage.phy_amount + damage.mag_amount)
		StatisticalData.register_damage(damage.source_weapon.player_id, damage.source_weapon.weapon_id, damage.phy_amount + damage.mag_amount)
		
		# 处理其他伤害效果
		if damage.other and damage.other == "fragile":
			is_fragile = false
			effect_queue[Effect.FRAGILE].clear()
			
		pending_damages.erase(damage)
		
	velocity -= max_knockback_damage.direction * max_knockback_damage.knockback

func create_damage(source_weapon: WeaponBase, direct_object: Variant, is_slave: bool = false) -> void:
	var damage = Damage.new()
	damage.source_weapon = source_weapon
	damage.direct_object = direct_object
	damage.direction = (damage.direct_object.global_position - global_position).normalized()
	
	# 计算该次伤害是否暴击以及伤害值
	damage.is_critical = Tools.is_success(damage.direct_object.attributes["CRIT_RATE"])
	if damage.is_critical:
		damage.source_weapon.critical_success.emit(self)
	damage.phy_amount = damage.direct_object.attributes["PHY_ATK"] if not damage.is_critical else damage.direct_object.attributes["PHY_ATK"] * damage.direct_object.attributes["CRIT_DMG"]
	damage.mag_amount = damage.direct_object.attributes["MAG_ATK"] if not damage.is_critical else damage.direct_object.attributes["MAG_ATK"] * damage.direct_object.attributes["CRIT_DMG"]
	
	# 计算该次伤害的击退值
	var knockback = damage.direct_object.attributes["KNOCKBACK"] * (1 - max(1.0, attributes["KNB_RES"]))
	if is_fragile:
		damage.knockback = knockback * (1 + effect_queue[Effect.FRAGILE][0].other)
	else:
		damage.knockback = knockback

	# 判断是否是从hitbox造成的伤害，是的话则使用slave_damage_multiplier进行修正伤害
	if is_slave:
		damage.phy_amount *= source_weapon.slave_damage_multiplier
		damage.mag_amount *= source_weapon.slave_damage_multiplier
		damage.knockback *= source_weapon.slave_knockback_multiplier
		
	# 计算特殊效果
	if "kill_rate" in source_weapon:
		if direct_object is LightingChain:
			pass
		else:
			if Tools.is_success(source_weapon.kill_rate):
				damage.phy_amount = attributes["HP"]
				damage.mag_amount = 0.0
	
	if is_fragile:
		var fragile_damage = Damage.new()
		fragile_damage.source_weapon = effect_queue[Effect.FRAGILE][0].source_weapon
		fragile_damage.direct_object = direct_object
		fragile_damage.direction = damage.direction
		
		fragile_damage.is_critical = false
		fragile_damage.phy_amount = 0.0
		fragile_damage.mag_amount = attributes["MAX_HP"] * effect_queue[Effect.FRAGILE][0].value
		fragile_damage.knockback = 0.0
		
		fragile_damage.other = "fragile"
		
		pending_damages.append(fragile_damage)
		
	pending_damages.append(damage)

func create_effets(source_weapon: WeaponBase, direct_object: Variant) -> void:
	if is_dead:
		return
			
	# >>>>>>>>>>>>>>>>>>>> 处理减速 >>>>>>>>>>>>>>>>>>>>
	if direct_object.attributes.has("SLOW_RATE"):
		var slow_rate = direct_object.attributes["SLOW_RATE"] * (1 - attributes["SLOW_RES"])
		if slow_rate > 0.0:
			var _effect = effect.new()
			_effect.value = slow_rate
			_effect.duration = direct_object.attributes["DECEL_DUR"] * (1 - attributes["SLOW_RES"])
			_effect.source_weapon = source_weapon
			effect_queue[Effect.SLOW].append(_effect)
			effect_queue[Effect.SLOW].sort_custom(compare_effects)

			is_slow = true
		
	# >>>>>>>>>>>>>>>>>>>> 处理冻结 >>>>>>>>>>>>>>>>>>>>
	if direct_object.attributes.has("FREEZE_RATE"):
		if not is_freeze:
			var is_freeze_success = Tools.is_success(direct_object.attributes["FREEZE_RATE"])
			if is_freeze_success:
				source_weapon.freeze_success.emit(self)
				var _effect = effect.new()
				_effect.value = 0.95 # 在冻结情况下被迫移动的话，速度每帧乘以的倍率
				_effect.duration = 2.0 * (1 - attributes["FRZ_RES"])
				_effect.source_weapon = source_weapon
				effect_queue[Effect.FREEZE].append(_effect)
				
				is_freeze = true

	## >>>>>>>>>>>>>>>>>>>> 处理中毒 >>>>>>>>>>>>>>>>>>>>
	#var new_poison_layers = direct_object.weapon_stats.attributes[WeaponAttrManager.Attr.POISON_LAY]
	#var max_poison_layers = direct_object.weapon_stats.attributes[WeaponAttrManager.Attr.MAX_POISON]
	#if new_poison_layers > 0:
		#if not is_poision:
			#var _effect = effect.new()
			#_effect.value = new_poison_layers
			#_effect.duration = 5
			#_effect.source_weapon = source_weapon
			#
			#_effect.other = 0.0
			#effect_queue[Effect.POISION].append(_effect)
#
			#is_poision = true
		#else :
			#effect_queue[Effect.POISION][0].value = min(effect_queue[Effect.POISION][0].value + new_poison_layers, max_poison_layers)


	if not is_fragile and not fragile_animated_sprite_2d.is_playing():
		if "fragile_ratio" in source_weapon:
			var _effect = effect.new()
			_effect.value = source_weapon.fragile_ratio
			_effect.duration = 5
			_effect.source_weapon = source_weapon
			_effect.other = source_weapon.knockback_multiplier
			
			effect_queue[Effect.FRAGILE].append(_effect)
			is_fragile = true

func create_damage_numbers(current_damage: Damage) -> void:
	if current_damage.phy_amount != 0:
		var damage_number = DAMAGE_NUMBERS.instantiate()
		damage_number.global_position = damage_number_marker_2d.global_position
		damage_number.velocity = Vector2(randf_range(-50, 50), randf_range(-200, -120))
		damage_number.gravity = Vector2(0, 2.0)
		damage_number.mass = 200
		damage_number.text = current_damage.phy_amount
		damage_number.type = "phy"
		damage_number.is_critical = current_damage.is_critical
		Game.add_object(damage_number)
	if current_damage.mag_amount != 0:
		var damage_number = DAMAGE_NUMBERS.instantiate()
		damage_number.global_position = damage_number_marker_2d.global_position
		damage_number.velocity = Vector2(randf_range(-50, 50), randf_range(-200, -120))
		damage_number.gravity = Vector2(0, 2.0)
		damage_number.mass = 200
		damage_number.text = current_damage.mag_amount
		damage_number.type = "mag"
		damage_number.is_critical = current_damage.is_critical
		Game.add_object(damage_number)

func init_attributes() -> void:
	for key in base_attributes.keys():
		attributes[key] = base_attributes[key]
		attributes_source[key] = {}
		recalculate(key)

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
	attributes[attr] = (base_attributes[attr] + fixed_total) * (1 + mult_total)
			
	var value = attributes[attr]
	
	# 应用效果
	match attr:
		"HP":
			attributes[attr] = clampf(value, 0, attributes["MAX_HP"])
			texture_progress_bar.value = value / attributes["MAX_HP"]
			
	recalculate_attribute.emit(attr, value)

func enemy_randomize() -> void:
	'''
		怪物随机化
	
	param from: 随机范围起始值
	param to: 随机范围结束值
	'''
	rand_float = randf_range(enemy_rand_range.x, enemy_rand_range.y)

	# 随机倍率影响大小
	scale = Vector2(randf_range(0.95, 1.05) * scale.x, randf_range(0.95, 1.05) * scale.y) * rand_float

	# 随机倍率影响速度
	update_attributes.emit("MOV_SPD", "RANDOMIZE", AttrType.MULT, 1/rand_float - 1)
	animation_player.speed_scale *= 1/rand_float

	# 随机倍率影响生命值
	update_attributes.emit("MAX_HP", "RANDOMIZE", AttrType.MULT, rand_float - 1)
	
func get_random_player() -> PlayerBase:
	'''
		获取随机玩家对象
	
	return: 随机玩家对象
	'''
	var players := get_tree().get_nodes_in_group("player")
	return players[Tools.rng.randi_range(0, players.size() - 1)]

func get_nearest_player() -> PlayerBase:
	'''
		获取最近的玩家对象
	
	return: 最近的玩家对象
	'''
	var players := get_tree().get_nodes_in_group("player")
	var nearest_player: PlayerBase = players[0]
	var nearest_distance = global_position.distance_squared_to(nearest_player.global_position)
	for player in players:
		var distance = global_position.distance_squared_to(player.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_player = player
	return nearest_player

func calculate_velocity_to_target(delta: float) -> void:
	'''
		移动到目标
	
	param target: 目标
	param delta: 时间间隔
	'''
	if target == null or is_freeze:
		return
	var target_position := target.global_position
	var pos := global_position
	var dir := (target_position - pos).normalized()
	velocity = velocity.move_toward(dir * attributes["MOV_SPD"], attributes["ACCEL"] * delta) 
	direction = Direction.LEFT if dir.x < 0 else Direction.RIGHT
	
func toward_target_player() -> void:
	var dir := (target.global_position - global_position).normalized()
	direction = Direction.RIGHT if dir.x > 0 else Direction.LEFT

func must_do_nothing() -> bool:
	if is_dead:
		return true
	return false

func die() -> void:
	'''
		死亡
	'''
	sync_free.rpc()
	
@rpc("authority", "call_local")
func sync_free() -> void:
	queue_free()
	
func compare_effects(a, b):
	if a.value > b.value:
		return true
	else:
		return false
		
func apply_enemy_texture():
	if not is_node_ready(): await ready
	var base_path = get_script().resource_path.get_base_dir()
	var texture_path = base_path + "/" + enemy_type + ".png"
	sprite_2d.texture = load(texture_path)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 回调函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func _on_hurt_box_hurt(hitbox: HitBox) -> void:
	var source_weapon: WeaponBase
	if hitbox.owner is WeaponBase:
		source_weapon = hitbox.owner
	else:
		source_weapon = hitbox.owner.weapon
	var direct_object = hitbox.owner
	var is_slave: bool = false
	if hitbox.slave_mode:
		is_slave = true
	create_damage(source_weapon, direct_object, is_slave)
	create_effets(source_weapon, direct_object)
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die" or anim_name == "ShadeLike/die":
		coin_generator.generate_coins(coin_value, coin_count)
		coin_generator.generate_energy(energy_value)
		die()

func _on_health_regeneration_timer_timeout() -> void:
	if not is_dead:
		update_attributes.emit("HP", "HP_REGEN", AttrType.FIXED, attributes["HP_REGEN"] * health_regeneration_timer.wait_time)
		#enemy_stats.current_health += enemy_stats.health_regen_rate * health_regeneration_timer.wait_time
		
func _on_update_attributes(attr: String, source: Variant, type: AttrType, value: float) -> void:
	if not base_attributes.has(attr): 
		return

	if not attributes_source[attr].has(source):
		attributes_source[attr][source] = {}
		
	attributes_source[attr][source][type] = attributes_source[attr][source].get(type, 0) + value

	recalculate(attr)
