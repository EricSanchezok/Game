class_name LightingChain
extends Sprite2D

const LIGHTING_CHAIN = preload("res://src/main/scene/role/effect/LightingChainV2/lighting_chain.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var search_collision_shape_2d: CollisionShape2D = $SearchBox/CollisionShape2D

@export var allow_repeat_attacks: bool = false
@export var speed: float = 1000.0
@export var radius: float = 50.0:
	set(v):
		radius = v
		if not is_node_ready(): await ready
		search_collision_shape_2d.shape.radius = radius

# 生成时传递的参数
var remaining_connections: int
var player: PlayerBase
var weapon: WeaponBase
var current_enemy: EnemyBase
var damage_current: bool
var former_enemies: Array

# 属性
var attributes: Dictionary

var enemies: Array[EnemyBase] = []

var star_flag: bool = false
var first_tick: bool = true
var need_search_enemy: bool = true
var target_enemy: EnemyBase
var target_position: Vector2

@export var length: float = 0.0:
	set(v):
		length = v
		if not is_node_ready(): await ready
		offset = Vector2(0, length / 2)
		region_rect = Rect2(0, 0, 288, length)

func _ready() -> void:
	attributes = weapon.attributes.duplicate(true)
	
	attributes["PHY_ATK"] = 0.0
	attributes["MAG_ATK"] = attributes["LCH_DMG"] * (attributes["PHY_ATK"] + attributes["MAG_ATK"])
	attributes["KNOCKBACK"] = 0.0
	
	if not is_instance_valid(current_enemy):
		sync_free.rpc()
		return

	global_position = current_enemy.global_position
	
	former_enemies.append(current_enemy)

	if not is_multiplayer_authority():
		return
		
	update_animation.rpc("idle")

	if damage_current:
		attack_current_enemy.rpc()
	

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	if first_tick:
		if enemies.size() > 0:
			first_tick = false
		return
	
	if need_search_enemy:
		need_search_enemy = false
		target_enemy = get_nearest_enemy()
		if is_instance_valid(target_enemy):
			star_flag = true
		else:
			update_animation.rpc("finish")
	
	if not star_flag: 
		return
	
	if is_instance_valid(target_enemy):
		target_position = target_enemy.global_position

	var distance = global_position.distance_to(target_position)
	length = clampf(length + speed * delta, 0.0, distance)

	look_at(target_position)
	rotation_degrees -= 90

	if length >= distance:
		star_flag = false
		if is_instance_valid(target_enemy):
			attack_target_enemy.rpc()
		
		if remaining_connections > 0:
			add_new_lighting_chain.rpc()
			
		update_animation.rpc("finish")

		
@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

@rpc("authority", "call_local")
func sync_free() -> void:
	queue_free()

@rpc("authority", "call_local")
func attack_current_enemy() -> void:
	current_enemy.create_damage(weapon, self)
	current_enemy.create_effets(weapon, self)

@rpc("authority", "call_local")
func attack_target_enemy() -> void:
	target_enemy.create_damage(weapon, self)
	target_enemy.create_effets(weapon, self)

@rpc("authority", "call_local")
func add_new_lighting_chain() -> void:
	var instance = LIGHTING_CHAIN.instantiate()
	instance.remaining_connections = remaining_connections - 1
	instance.player = player
	instance.weapon = weapon
	instance.current_enemy = target_enemy
	instance.damage_current = false
	instance.former_enemies = former_enemies

	Game.add_object(instance)

func get_nearest_enemy() -> EnemyBase:
	var nearest_enemy: EnemyBase = null
	var distance = INF
	for enemy in enemies:
		if enemy == current_enemy:
			continue
		if not allow_repeat_attacks and enemy in former_enemies:
			continue
		var _distance = enemy.global_position.distance_squared_to(global_position)
		if _distance < distance:
			distance = _distance
			nearest_enemy = enemy

	return nearest_enemy

func _on_search_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not enemies.has(body):
		enemies.append(body)

func _on_search_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemy") and enemies.has(body):
		enemies.erase(body)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if not is_multiplayer_authority():
		return

	if anim_name == "finish":
		sync_free.rpc()
