extends EnemyShootBase


func _ready() -> void:
	set_process(false)
	
	animation_player.play("explode")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		sync_free.rpc()
