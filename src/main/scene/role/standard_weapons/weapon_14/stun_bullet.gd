extends ProjectileBase


func _ready() -> void:
	super()
	
	update_animation.rpc("idle")

func _on_reach_target() -> void:
	super()
	
	update_animation.rpc("finish")
	
func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	deferred_add_lighting_chain.call_deferred()

