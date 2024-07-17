extends ProjectileBase


func _ready() -> void:
	super()
	
	is_dir_mode = true
	
	animation_player.play("idle")


func _on_reach_target() -> void:
	super()
	
	animation_player.play("finish")

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	deferred_add_lighting_chain.call_deferred()
