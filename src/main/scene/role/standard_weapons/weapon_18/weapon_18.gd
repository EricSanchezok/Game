extends BookAndScrollBase

const ELECTRIC_SHOCK = preload("res://src/main/scene/role/standard_weapons/weapon_18/electric_shock.tscn")

@export var summon_wait_time: float = 0.5
var current_time_left: float:
	set(v):
		current_time_left = clampf(v, 0, summon_wait_time)

func _ready() -> void:
	super()
	scroll = true
	is_book_like = true
	
func level_up(level: int) -> void:
	super(level)
	
func do_tick(delta: float) -> void:
	return
	print(attack_cooldown_time)

func do_tick_trigger(delta: float) -> void:
	current_time_left -= delta
	if current_time_left <= 0:
		shoot_flag = true
		recovery_summon_time()

func do_enter_trigger() -> void:
	recovery_summon_time()
	
func shoot() -> void:
	add_bullet()
	
func add_bullet() -> void:
	target = get_random_enemy()
	if is_instance_valid(target):
		var instance = ELECTRIC_SHOCK.instantiate()
		instance.player_id = player_id
		instance.slot_id = slot_id
		instance.target = target
		instance.global_position = target.global_position
		
		Levels.activated_level.add_child(instance, true)

func recovery_summon_time() -> void:
	current_time_left = summon_wait_time
