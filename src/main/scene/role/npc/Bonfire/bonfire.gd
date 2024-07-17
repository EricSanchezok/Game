extends Npc

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var fire_energy: float 


func _ready() -> void:
	super()
	await owner.ready
	animation_player.play("idle")
	# atmosphere_system.register_light(point_light_2d, 0.10, 0.25, 0.4, 0.25, 1.0)

func _on_interactable_interacted(player: PlayerBase) -> void:
	print("还没改我呢，别急！")

#func _on_highlight() -> void:
	#fire_energy = point_light_2d.energy
	#var tween_time = 1.2
	#Tools.ease_in_bgm($FireSound, -10, 0, tween_time)
	#var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	#tween.parallel().tween_property(point_light_2d, "energy", fire_energy*1.5, tween_time)
	#tween.parallel().tween_property(animation_player, "speed_scale", 1.5, tween_time)
	#
#func _on_unhighlight() -> void:
	#var tween_time = 1.2
	#Tools.ease_in_bgm($FireSound, 0, -10, tween_time)
	#var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	#tween.parallel().tween_property(point_light_2d, "energy", fire_energy, tween_time)
	#tween.parallel().tween_property(animation_player, "speed_scale", 1.0, tween_time)
