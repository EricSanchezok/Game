class_name PlayerBase
extends CharacterBody2D

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 导入模块 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@onready var wam: WeaponAttributeManager = $WeaponAttributeManager ## 属性管理器节点
@onready var animation_player: AnimationPlayer = $AnimationPlayer ## 动画播放器节点
@onready var camera_2d: Camera2D = $Camera2D ## 2D 相机节点
@onready var graphics: Node2D = $Graphics ## 角色图形节点
@onready var health_bar: TextureProgressBar = $HealthBar ## 血条节点
@onready var hurt_box: HurtBox = $Graphics/HurtBox ## 受伤盒节点
@onready var hurt_box_collision_shape_2d: CollisionShape2D = $Graphics/HurtBox/CollisionShape2D ## 受伤盒碰撞体节点
@onready var invincible_timer: Timer = $InvincibleTimer ## 无敌计时器节点

@onready var pause_screen: Control = $CanvasLayer/PauseScreen


enum AttrType {
	FIXED, MULT
}

var base_attributes = { ## 基础属性
	"MAX_HP": 10.0,
	"HP": 10.0,
	"HP_REGEN": 0.0,
	"SHIELD": 0.0,
	"DMG_RED": 0.0,
	"MOV_SPD": 150.0,
	"ACCEL": 2000.0,
	"DECEL": 3000.0,
	"EXP_GAIN": 0.0
}
var attributes_source = {}  ## 属性来源
var attributes: Dictionary ## 当前属性

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 常规变量定义 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
var multiplayer_id: int ## 多人游戏中的玩家ID，如果为 1 则表示是主机
var traits_count = {} ## 玩家拥有的羁绊数量的数组，每个元素表示对应羁绊的数量

enum Direction { ## 玩家的朝向
	LEFT = -1, ## 左
	RIGHT = +1 ## 右
}

var interacting_with: Array[Interactable] ## 玩家正在交互的对象数组
var pending_damage: float ## 玩家受到的伤害，会在 hurt 状态中计算

# >>>>>>>>>>>>>>>>>>>> 武器槽参数 >>>>>>>>>>>>>>>>>>>>
var slots = [] ## 武器槽数组，包含 10 个武器槽的节点
var slot_height: float = -24 ## 横向武器槽的高度
var slot_space: float = 12.0 ## 横向武器槽之间的间隔
var slot_radius: float = 60.0 ## 圆周武器槽的半径
var slot_speed_rotation: float = 30.0 ## 圆周武器槽的旋转速度
var amplitude: float = 2.0 ## 横向武器槽的振幅
var frequency: float = 0.2 ## 横向武器槽的频率
var current_time: float = 0.0 ## 当前时间，内部变量，无需关注

# >>>>>>>>>>>>>>>>>>>> 武器相关 >>>>>>>>>>>>>>>>>>>>
var kills: int = 0
var max_level_weapons = [] ## 玩家拥有的最高等级武器的数组，当一个武器达到最高等级后，会在这个数组中记录，以字典的形式记录武器的ID和对象

# >>>>>>>>>>>>>>>>>>>> 金币和能量相关 >>>>>>>>>>>>>>>>>>>>
var coin_count: int = 0: ## 玩家拥有的金币数量
	set(v):
		coin_count = v
		coin_count_changed.emit(coin_count)
var energy_count: float = 0: ## 玩家拥有的能量数量
	set(v):
		energy_count = v
		energy_count_changed.emit(energy_count)
var max_energy: float = 100.0 ## 玩家的最大能量值，当达到这个值时，进入强化界面

# >>>>>>>>>>>>>>>>>>>> 武器抽取相关 >>>>>>>>>>>>>>>>>>>>
var draw_result_queue: Array = [] ## 武器抽取结果队列，用于存储抽取的武器结果，当向 WeaponsManager 请求抽取武器时，会将结果存储在这个队列中
var player_level: int = 1: ## 玩家的等级，用于控制武器的抽取等级和允许注册的武器数量，当玩家升级时，会触发 player_level_changed 信号，该信号会通知UI更新玩家等级
	set(v):
		player_level = v
		player_level_changed.emit(player_level)

# >>>>>>>>>>>>>>>>>>>> 状态变量相关 >>>>>>>>>>>>>>>>>>>>
var direction := Direction.RIGHT: ## 玩家的当前朝向
	set(v):
		direction = v
		if not is_node_ready(): await ready
		graphics.scale.x = direction

var is_dead: bool = false: ## 玩家是否死亡
	set(v):
		is_dead = v
		if is_dead:
			player_die.emit(self)
var lock_input: bool = false ## 锁定输入，用于在特定情况下禁止玩家输入，当为true时玩家的任何按键将被忽略
var is_moving: bool = false ## 玩家是否在移动状态
var movement: Vector2 ## 玩家的移动方向，会在每一帧中根据输入更新

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 信号定义 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
signal register_weapon(player_id: int, weapon_id: int, slot_id: int) ## 注册武器信号，当卡牌被放入装备槽位时，会触发这个信号，生成对应的武器
signal unregister_weapon(player_id: int, slot_id: int) ## 注销武器信号，当卡牌被移除装备槽位时，会触发这个信号，销毁对应的武器
signal finish_shop_screen(player: PlayerBase) ## 完成商店界面信号，当玩家结束商店界面时，会触发这个信号，用于关卡进入下一阶段
signal traits_count_changed(type: String, value: int) ## 羁绊数量变化信号，当玩家的羁绊数量发生变化时，会触发这个信号，用于更新UI或者通知trait节点更新数据
signal coin_count_changed(value) ## 金币数量变化信号，当玩家的金币数量发生变化时，会触发这个信号，用于更新UI
signal energy_count_changed(value) ## 能量数量变化信号，当玩家的能量数量发生变化时，会触发这个信号，用于更新UI
signal player_level_changed(value) ## 玩家等级变化信号，当玩家的等级发生变化时，会触发这个信号，用于更新UI
signal kill_success(enemy: EnemyBase) ## 成功击杀敌人信号，当玩家成功击杀敌人时，会在敌人中触发这个信号
signal player_die(player: PlayerBase) ## 玩家死亡信号，当玩家死亡时，会触发这个信号，用于处理玩家死亡的逻辑
signal life_steal_success(enemy: EnemyBase, value: float)
signal recalculate_attribute(attr: String, value: float) ## 某个属性被重新计算了
signal update_attributes(attr: String, source: Variant, type: AttrType, value: float) ## 激发这个信号来更新玩家的参数

func _ready() -> void:
	# print("My id is ", multiplayer_id, ", name: ", name, ", my autority is ", is_multiplayer_authority())

	if not is_multiplayer_authority():
		camera_2d.enabled = false
		
	for key in base_attributes.keys():
		attributes[key] = base_attributes[key]
		attributes_source[key] = {}
		recalculate(key)
	update_attributes.connect(_on_update_attributes)
	
	Game.start_game.connect(_on_start_game)
	Game.leave_game.connect(_on_leave_game)

	for _trait in wam.trait_attributes:
		traits_count[_trait] = 0

	slots = $WeaponSlots.get_children()
	init_slots()

	life_steal_success.connect(_on_life_steal_success)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 状态机 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
enum State {
	IDLE,
	RUN,
	HURT,
	DIE,
}

func tick_physics(state: State, delta: float) -> void:
	move_slots(delta)

	movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	do_tick_invincible()

	match state:
		State.IDLE, State.DIE:
			slow_down(delta)
		State.RUN, State.HURT:
			change_direction()
			speed_up(delta)

	move_and_collide(velocity * delta)

func get_next_state(state: State) -> int:
	if attributes["HP"] <= 0:
		return StateMachine.KEEP_CURRENT if state == State.DIE else State.DIE

	if pending_damage != 0:
		return State.HURT

	var is_still := movement.is_zero_approx()

	match state:
		State.IDLE:
			if not is_still:
				return State.RUN
		State.RUN:
			if is_still:
				return State.IDLE
		State.HURT:
			if not animation_player.is_playing():
				return State.IDLE
		State.DIE:
			pass

	return StateMachine.KEEP_CURRENT

func transition_state(from: State, to: State) -> void:
	# print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 

	match from:
		State.IDLE, State.RUN, State.HURT, State.DIE:
			pass

	match to:
		State.IDLE:
			update_animation.rpc("idle")
		State.RUN:
			update_animation.rpc("run")
		State.HURT:
			invincible_timer.start()
			hurt_box_collision_shape_2d.disabled = true
			if attributes["SHIELD"] > 0:
				if attributes["SHIELD"] >= pending_damage:
					# attributes["SHIELD"] -= pending_damage
					update_attributes.emit("SHIELD", "HURT", AttrType.FIXED, -pending_damage)
				else:
					var remaining_damage = pending_damage - attributes["SHIELD"]
					update_attributes.emit("SHIELD", "HURT", AttrType.FIXED, -attributes["SHIELD"])
					update_attributes.emit("HP", "HURT", AttrType.FIXED, -remaining_damage)
					#attributes["SHIELD"] = 0
					#attributes["HP"] -= remaining_damage
			else:
				update_attributes.emit("HP", "HURT", AttrType.FIXED, -pending_damage)
				#attributes["HP"] -= pending_damage
			pending_damage = 0
			update_animation.rpc("hurt")
		State.DIE:
			is_dead = true
			hurt_box_collision_shape_2d.disabled = true
			update_animation.rpc("die")

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 功能函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@rpc("any_peer", "call_local", "reliable")
func change_coin(value: int) -> void:
	coin_count += value

@rpc("any_peer", "call_local", "reliable")
func change_energy(value: float) -> void:
	energy_count = clampf(energy_count + value, 0, max_energy)

@rpc("any_peer", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

func register_interactable(v: Interactable) -> void:
	if v in interacting_with:
		return
	interacting_with.append(v)

func unregister_interactable(v: Interactable) -> void:
	interacting_with.erase(v)

func do_nothing() -> void:
	pass

func slow_down(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, attributes["DECEL"] * delta)
	is_moving = not velocity.is_zero_approx()

func speed_up(delta: float) -> void:
	velocity = velocity.move_toward(attributes["MOV_SPD"] * movement.normalized(), attributes["ACCEL"] * delta)
	is_moving = not velocity.is_zero_approx()

func change_direction() -> void:
	if not movement.is_zero_approx():
		direction = Direction.LEFT if movement.x < 0 else Direction.RIGHT

func do_tick_invincible() -> void:
	graphics.modulate.a = (sin(Time.get_ticks_msec() / 20.0) * 0.5 + 0.5) if invincible_timer.time_left > 0 else 1.0

func get_weapon_slot(index: int) -> Marker2D:
	return slots[index]

func init_slots() -> void:
	for i in range(0, 5):
		slots[i].position = Vector2(-2 * slot_space + i * slot_space, slot_height)
	for i in range(5, 10):
		slots[i].position = Vector2(cos(deg_to_rad(72 * (i - 5))) * slot_radius, sin(deg_to_rad(72 * (i - 5))) * slot_radius)

func move_slots(delta) -> void:
	for i in range(0, 5):
		slots[i].position.y = slot_height + sin(current_time + i * frequency) * amplitude
	for i in range(5, 10):
		slots[i].position = Vector2(
			cos(deg_to_rad(72 * (i - 5) + slot_speed_rotation * current_time)) * slot_radius,
			sin(deg_to_rad(72 * (i - 5) + slot_speed_rotation * current_time)) * slot_radius,
		)
	current_time += delta

func update_traits_count(type: String, value: int):
	traits_count[type] += value
	traits_count_changed.emit(type, value)
	
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
				
		"SHIELD":
			pass
			
	recalculate_attribute.emit(attr, value)

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 回调函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority() or lock_input:
		return

	if event.is_action_pressed("shop"):
		if not Game.is_game_start():
			return

	if event.is_action_pressed("interact") and interacting_with:
		interacting_with.back().interact(self)

	if event.is_action_pressed("esc"):
		pause_screen.switch()

func _on_start_game(level: Node2D) -> void:
	health_bar.show()
	
func _on_leave_game(level: Node2D) -> void:
	health_bar.hide()

func _on_hurt_box_hurt(hitbox: Variant) -> void:
	var source: CharacterBody2D = hitbox.owner
	pending_damage = source.attributes["DMG"]

func _on_invincible_timer_timeout() -> void:
	hurt_box_collision_shape_2d.disabled = false

func _on_life_steal_success(enemy: EnemyBase, value: float) -> void:
	pass

func _on_update_attributes(attr: String, source: Variant, type: AttrType, value: float) -> void:
	if not base_attributes.has(attr): 
		return

	if not attributes_source[attr].has(source):
		attributes_source[attr][source] = {}
		
	attributes_source[attr][source][type] = attributes_source[attr][source].get(type, 0) + value

	recalculate(attr)
