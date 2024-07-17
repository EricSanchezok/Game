#extends ProjectileBase
#
#@onready var explode_audio: AudioStreamPlayer = $ExplodeAudio
#
### 有bug，先不要用
#
#func _ready() -> void:
	#super()
	#
	## weapon_stats.attributes[WeaponAttrManager.Attr.SPAWN_SIZE] = weapon.weapon_stats.attributes[WeaponAttrManager.Attr.SPAWN_SIZE]
	#weapon_stats.spawn_object_size_multiplier = weapon.weapon_stats.spawn_object_size_multiplier
	#
	#weapon_stats.physical_attack_power = 200.0
	#weapon_stats.magic_attack_power = 200.0
	#weapon_stats.fly_speed = 300.0
	#weapon_stats.knockback_strength = 200.0
	#weapon_stats.penetration_rate = 1.0
	#
	#acceleration = 500.0
	#
	#global_position = target_pos + Vector2(0, -1000)
	#
#func _process(delta: float) -> void:
	#super(delta)
#
#func _on_reach_target() -> void:
	#super()
	#
	#explode_audio.pitch_scale = randf_range(0.8, 1.2)
	#update_animation.rpc("finish")
