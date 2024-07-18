extends BookAndScrollBase
## 20240628: 当前版本是在一个距离玩家一个半径范围内的圆内召唤区域

const ROCK_AREA = preload("res://src/main/scene/role/standard_weapons/weapon_23/rock_area.tscn")

var shield_increment: float = 2.0 ## （调整参数）区域内玩家每秒钟增加的护盾量
var knockback_increment: float = 0.5 ## （调整参数）击退的增加倍率
var pen_rate_increment: float = 0.2 ## （调整参数）穿透率的增加倍率
var enemy_bullet_speed_multiplier: float = 0.2 ## （调整参数）敌人子弹的速度倍率
var spawn_radius: float = 200 ## （调整参数）生成的位置距离玩家的半径范围（理论上应该是越小越好）


func _ready() -> void:
	super()
	
	is_book_like = true
	
func level_up(level: int) -> void:
	super(level)
	
	match level:
		2:
			spawn_radius = 120
		3:
			spawn_radius = 60
	
func do_enter_trigger() -> void:
	var pos = get_spawn_position()
	spawn_area(pos)
	
func spawn_area(pos: Vector2) -> void:
	var instance = ROCK_AREA.instantiate()
	instance.global_position = pos
	instance.weapon = self
	instance.shield_increment = shield_increment
	instance.knockback_increment = knockback_increment
	instance.pen_rate_increment = pen_rate_increment
	instance.enemy_bullet_speed_multiplier = enemy_bullet_speed_multiplier
	
	Game.add_object(instance)

func get_spawn_position() -> Vector2:
	var angle = randf_range(0, 2 * PI)
	var distance = randf_range(0, spawn_radius)
	return Vector2(cos(angle), sin(angle)) * distance + player.global_position
