extends ProjectileBase


func _ready() -> void:
	super()
	
	is_dir_mode = true
	acceleration = 300


func _on_reach_target() -> void:
	super()
	
	update_animation.rpc("finish")
