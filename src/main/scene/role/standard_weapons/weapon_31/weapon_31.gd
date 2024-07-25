extends SpearBase



func _ready() -> void:
	super()
	
func level_up(level: int) -> void:
	super(level)

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	hit_enemy.is_posion_life_steal = true
