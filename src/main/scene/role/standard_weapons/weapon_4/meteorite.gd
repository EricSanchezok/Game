extends ProjectileBase

@onready var fire: GPUParticles2D = $Fire
@onready var spark: GPUParticles2D = $Fire/Spark

var knockback_multipler: float = 1.5 ## （调整参数）击退相对于父武器的倍率
var phy_damage_multipler: float = 1.2 ## （调整参数）物理伤害相对于父武器的倍率
var mag_damage_multipler: float = 1.0 ## （调整参数）魔法伤害相对于父武器的倍率

func _ready() -> void:
	super()
	
	attributes["KNOCKBACK"] *= knockback_multipler
	attributes["PHY_ATK"] *= phy_damage_multipler
	attributes["MAG_ATK"] *= mag_damage_multipler
	
	tracking = true
	acceleration = 500
	
	fire.emitting = true
	spark.emitting = true
	
	target = Tools.get_random_enemy()
	target_pos = target.global_position
	
	global_position = target_pos + Vector2(randf_range(200, 400), -600)
	
	update_animation.rpc("idle")


func _on_reach_target() -> void:
	super()
	update_animation.rpc("finish")
	





