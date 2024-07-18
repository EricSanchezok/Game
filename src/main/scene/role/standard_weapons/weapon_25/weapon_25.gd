extends StaffBase
## 20240628: 当前版本中，这个法杖的子弹可以阻拦敌人的子弹
const STONE_BALL = preload("res://src/main/scene/role/standard_weapons/weapon_25/stone_ball.tscn")

func _ready() -> void:
	super()
	
	is_staff_like = true

func level_up(level: int) -> void:
	super(level)

func shoot() -> void:
	add_bullet.rpc()
	
@rpc("authority", "call_local")
func add_bullet() -> void:
	for index in attributes["PROJ_COUNT"]:
		var target_enemy: EnemyBase = get_random_enemy()
		
		if target_enemy:
			var instance = STONE_BALL.instantiate()
			instance.player_id = player_id
			instance.slot_id = slot_id
			instance.init_rotation = (target_enemy.global_position - global_position).angle()
			instance.init_position = shoot_marker_2d.global_position
			
			instance.target = target_enemy

			Game.add_object(instance)
