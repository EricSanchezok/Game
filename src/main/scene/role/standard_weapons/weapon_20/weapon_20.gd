extends StationBase

const LIGHTNING_LINK = preload("res://src/main/scene/role/effect/LightningLink/lightning_link.tscn")

# 不知道为什么，闪电链V2是可以自己proload自己的，但是这里不行，会报错
# const WEAPON_20 = preload("res://src/main/scene/role/standard_weapons/weapon_20/weapon_20.tscn")

var is_main: bool = true
var weapons = []
var links = []

var spawn_finish: bool = false

func _ready() -> void:
	super()
	
	recalculate_attribute.connect(_on_recalculate_attribute)
	
	if not is_main:
		reload_progress_bar.hide()
		scale *= 0.5

func level_up(level: int) -> void:
	super(level)

func do_enter_wait() -> void:
	spawn_finish = false
	
func do_enter_trigger() -> void:
	if not is_main:
		return
		
	recovery_cooldown()
	# var instance = WEAPON_20.instantiate()
	var instance: WeaponBase = (load("res://src/main/scene/role/standard_weapons/weapon_20/weapon_20.tscn") as PackedScene).instantiate()
	instance.is_main = false
	
	instance.player_id = player_id
	instance.weapon_id = weapon_id
	instance.slot_id = slot_id
	
	Game.add_object(instance)
	
	scale_up()
	
	if not instance.is_node_ready(): await instance.ready # station 类会自动初始化位置，所以要先等待初始化完成再生成链接闪电
	
	var distance: float = global_position.distance_to(instance.global_position)
	
	var link_instance = LIGHTNING_LINK.instantiate()
	link_instance.global_position = global_position
	link_instance.look_at(instance.global_position)
	link_instance.rotation_degrees -= 90
	
	link_instance.player_id = player_id
	link_instance.weapon_id = weapon_id
	link_instance.slot_id = slot_id
	link_instance.target_length = distance
	
	weapons.append(instance)
	links.append(link_instance)
	
	Game.add_object(instance)
	
	spawn_finish = true

func scale_up() -> void:
	var tween_scale = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween_scale.parallel().tween_property(self, "scale", scale + Vector2(0.1, 0.1), 0.5)

func can_enter_wait() -> bool:
	return spawn_finish
	
func can_enter_trigger() -> bool:
	return cooling_complete()

func _on_recalculate_attribute(attr: String, value: float) -> void:
	for link in links:
		link.attributes[attr] = value
