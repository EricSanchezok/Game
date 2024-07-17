extends ProjectileBase

func _ready() -> void:
	super()

	tracking = true
	bezier = true
	in_front = true
	in_front_dis = 5
	
	acceleration = 500
	
	
func _on_reach_target() -> void:
	super()
	
	update_animation.rpc("finish")
