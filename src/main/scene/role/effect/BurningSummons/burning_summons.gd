extends CharacterBody2D


@onready var r_burning_path_gpu_particles_2d: GPUParticles2D = $R_BurningPathGPUParticles2D
@onready var r_spark_gpu_particles_2d: GPUParticles2D = $R_BurningPathGPUParticles2D/R_SparkGPUParticles2D

@onready var c_burning_path_gpu_particles_2d: GPUParticles2D = $C_BurningPathGPUParticles2D
@onready var c_spark_gpu_particles_2d: GPUParticles2D = $C_BurningPathGPUParticles2D/C_SparkGPUParticles2D

@onready var r_hit_box: HitBox = $RHitBox
@onready var rectangle_shape_2d: CollisionShape2D = $RHitBox/RectangleShape2D

@onready var c_hit_box: HitBox = $CHitBox
@onready var circle_shape_2d: CollisionShape2D = $CHitBox/CircleShape2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var hit_box_timer: Timer = $HitBoxTimer
@onready var life_timer: Timer = $LifeTimer

# 生成时传递的参数
var player_id: int 
var slot_id: int
var init_position: Vector2
var damage: float
var is_rectangle: bool
var r_size: Vector2
var c_radius: float
var life_time: float

var player: PlayerBase
var weapon: WeaponBase
var attributes: Dictionary
	
var base_burning_amount: int = 20
var base_spark_amount: int = 5
var base_r_size: Vector2 = Vector2(10, 10)
var base_c_radius: float = 5.0 
var active_hitbox: HitBox

func _ready() -> void:
	player = Tools.get_player(player_id)
	weapon = Tools.get_weapon(player_id, slot_id)
	attributes = weapon.attributes.duplicate(true)

	attributes["PHY_ATK"] = 0
	attributes["MAG_ATK"] = damage
	attributes["KNOCKBACK"] = 0
			
	global_position = init_position
	
	var ratio: float = r_size.x * r_size.y / (base_r_size.x * base_r_size.y) if is_rectangle else c_radius / base_c_radius
	if is_rectangle:
		r_burning_path_gpu_particles_2d.amount = int(ratio * base_burning_amount)
		r_spark_gpu_particles_2d.amount = int(ratio * base_spark_amount)
		
		rectangle_shape_2d.shape.size = r_size
		r_burning_path_gpu_particles_2d.process_material.emission_box_extents = Vector3(r_size.x, r_size.y, 0)
		r_spark_gpu_particles_2d.process_material.emission_box_extents = Vector3(r_size.x, r_size.y, 0)
		
		active_hitbox = r_hit_box
	else:
		c_burning_path_gpu_particles_2d.amount = int(ratio * base_burning_amount)
		c_spark_gpu_particles_2d.amount = int(ratio * base_spark_amount)
		
		circle_shape_2d.shape.radius = c_radius
		c_burning_path_gpu_particles_2d.process_material.emission_sphere_radius = c_radius
		c_spark_gpu_particles_2d.process_material.emission_sphere_radius = c_radius
		
		active_hitbox = c_hit_box
	
	update_animation.rpc("appear")
	
	life_timer.wait_time = life_time
	life_timer.start()
	
	hit_box_timer.start()
	
@rpc("authority", "call_local")
func update_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

@rpc("authority", "call_local")
func sync_free() -> void:
	queue_free()

func _on_hit_box_timer_timeout() -> void:
	if not is_multiplayer_authority():
		return
		
	active_hitbox.monitoring = false if active_hitbox.monitoring else true

func _on_life_timer_timeout() -> void:
	if not is_multiplayer_authority():
		return
		
	update_animation.rpc("disappear")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if not is_multiplayer_authority():
		return
		
	if anim_name == "disappear":
		sync_free.rpc()
