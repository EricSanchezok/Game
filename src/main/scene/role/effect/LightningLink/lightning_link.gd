extends Sprite2D

const LIGHTING_CHAIN = preload("res://src/main/scene/role/effect/LightingChainV2/lighting_chain.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $HitBox/CollisionShape2D

# 生成时传递的参数（老三样） 和 目标长度
var player_id: int
var weapon_id: int
var slot_id: int
var target_length: float

var player: PlayerBase
var weapon: WeaponBase
var attributes: Dictionary
var hit_enemy: EnemyBase

var speed: float = 1000.0

@export var length: float = 0.0:
	set(v):
		length = v
		if not is_node_ready(): await ready
		offset = Vector2(0, length / 2)
		region_rect = Rect2(0, 0, 288, length)
		
		collision_shape_2d.shape.size = Vector2(20, length)
		collision_shape_2d.position = Vector2(0, length / 2)

func _ready() -> void:
	player = Tools.get_player(player_id)
	weapon = Tools.get_weapon(player_id, slot_id)
	attributes = weapon.attributes.duplicate(true)
	
	#print(weapon_stats.physical_attack_power, " ", weapon_stats.magic_attack_power)
	
	animation_player.play("idle")
	
func _process(delta: float) -> void:
	if length >= target_length:
		return
	length = clampf(length + speed * delta, 0, target_length)
	
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

func _on_hit_box_timer_timeout() -> void:
	collision_shape_2d.disabled = true if not collision_shape_2d.disabled else false

func _on_hit_box_hit(hurtbox: Variant) -> void:
	hit_enemy = hurtbox.owner
	
	# deferred_add_lighting_chain.call_deferred()
