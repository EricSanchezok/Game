class_name EnemyProjectileBase
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var accept_rand: bool = true

## 注意，子弹被挡掉的逻辑是 子弹的 hurtbox 受到了 武器的 hitbox 的攻击
@export var can_be_stopped: bool = true

# 生成时传递的参数
var rand_float: float
var dir: Vector2
var speed: float
var life: float
var attributes: Dictionary
	
func _process(delta: float) -> void:
	global_position += dir * speed * delta
	life -= delta
	
	if life <= 0:
		sync_free.rpc()
		
func shoot_randomize() -> void:
	# 随机倍率影响大小
	scale = Vector2(randf_range(0.95, 1.05) * scale.x, randf_range(0.95, 1.05) * scale.y) * rand_float
	# 随机倍率影响速度
	speed *= 1/rand_float
	
@rpc("authority", "call_local")
func sync_free() -> void:
	queue_free()

func _on_hurt_box_hurt(hitbox: Variant) -> void:
	var source = hitbox.owner
	if source.stop_bullets and can_be_stopped:
		sync_free.rpc()
