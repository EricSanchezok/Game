extends ProjectileBase


func _ready() -> void:
	super()
	
	is_dir_mode = true
	
	animation_player.play("idle")


func _on_reach_target() -> void:
	super()
	
	animation_player.play("finish")
