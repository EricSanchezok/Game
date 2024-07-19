extends EnemyProjectileBase

func _ready() -> void:
	if not is_multiplayer_authority():
		return
		
	if accept_rand:
		shoot_randomize()
