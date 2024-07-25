extends ProjectileBase

func _ready() -> void:
	super()
	
	tracking = true
	bezier = true
	in_front = true
	
	in_front_dis = 5
	
	update_animation.rpc("idle")
	
	
func _on_reach_target() -> void:
	super()
	
	update_animation.rpc("finish")
