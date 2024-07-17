extends StationBase

@onready var hit_box_timer: Timer = $HitBoxTimer
@onready var fire_gpu_particles_2d: GPUParticles2D = $Graphics/FireGPUParticles2D

# 火焰粒子效果
@onready var base_particles_amount = fire_gpu_particles_2d.amount
@onready var base_scale_min = fire_gpu_particles_2d.process_material.scale_min
@onready var base_scale_max = fire_gpu_particles_2d.process_material.scale_max

var rand_dir: int = 1
var change_seconds: float = 2.0

func _ready() -> void:
	super()
	
	recalculate_attribute.connect(_on_recalculate_attribute)
	
func level_up(level: int) -> void:
	super(level)
	

func can_enter_trigger() -> bool:
	target = get_nearest_enemy(true)
	if target:
		return true
	return false
	
func can_enter_wait() -> bool:
	return not target or target not in enemies or target.is_dead

func do_tick_wait(delta: float) -> void:
	change_seconds -= delta
	sync_direction.rpc(graphics.rotation + deg_to_rad(attributes["ROT_SPD"]) * delta * rand_dir, deg_to_rad(attributes["ROT_SPD"]) * delta * 0.1)
	if change_seconds <= 0.0:
		if Tools.is_success(0.003):
			rand_dir *= -1
			change_seconds = 2.0
	
func do_tick_trigger(delta: float) -> void:
	towards_target.rpc(target.position, deg_to_rad(attributes["ROT_SPD"]) * delta)

func do_enter_wait() -> void:
	hit_box_timer.stop()
	cease_fire.rpc()
	
func do_enter_trigger() -> void:
	hit_box_timer.start()
	open_fire.rpc()
	
@rpc("authority", "call_local")
func open_fire() -> void:
	fire_gpu_particles_2d.emitting = true
	
@rpc("authority", "call_local")
func cease_fire() -> void:
	fire_gpu_particles_2d.emitting = false

func _on_hit_box_timer_timeout() -> void:
	hit_box.monitoring = false if hit_box.monitoring else true

func _on_recalculate_attribute(attr: String, value: float) -> void:
	if attr == "WEAPON_SIZE":
		var ratio = 1 + value
		# 该武器搜索范围和攻击范围属于绑定
		fire_gpu_particles_2d.amount = base_particles_amount * ratio
		fire_gpu_particles_2d.process_material.scale_min = base_scale_min * ratio
		fire_gpu_particles_2d.process_material.scale_max = base_scale_max * ratio
