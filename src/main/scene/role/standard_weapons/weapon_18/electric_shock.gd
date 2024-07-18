extends CharacterBody2D

const LIGHTING_CHAIN = preload("res://src/main/scene/role/effect/LightingChainV2/lighting_chain.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_id: int ## 生成投射物的玩家id，需要在生成时传递
var slot_id: int ## 生成投射物的武器槽位id， 需要在生成时传递
var target: EnemyBase ## 必须传递 target 参数

var player: PlayerBase ## 属于的玩家
var weapon: WeaponBase ## 属于的武器
var hit_enemy: EnemyBase
var attributes: Dictionary

func _ready() -> void:
	player = Tools.get_player(player_id)
	weapon = Tools.get_weapon(player_id, slot_id)
	
	attributes = weapon.attributes.duplicate(true)
	
	Tools.apply_spawn_object_size_multiplier(self)
	
	animation_player.play("finish")

#func _process(delta: float) -> void:
	#global_position = target.global_position
	
@rpc("authority", "call_local")
func sync_free() -> void:
	queue_free()
	
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

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "finish":
		sync_free.rpc()

func _on_hit_box_hit(hurtbox: Variant) -> void:
	hit_enemy = hurtbox.owner
	deferred_add_lighting_chain.call_deferred()
	
