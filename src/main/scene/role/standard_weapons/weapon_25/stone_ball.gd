extends ProjectileBase


func _ready() -> void:
	super()
	
	is_dir_mode = true
	stop_bullets = true
	
	update_animation.rpc("init")

func _on_reach_target() -> void:
	sync_free.rpc()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	super(anim_name)
	
	if anim_name == "init":
		update_animation.rpc("idle")
