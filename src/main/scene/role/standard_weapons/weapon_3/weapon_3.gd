extends AxeBase

const BURNING_SUMMONS = preload("res://src/main/scene/role/effect/BurningSummons/burning_summons.tscn")

var burning_damage: float = 0.5 ## （调整参数）燃烧区域的伤害(燃烧区域会每过0.2s产生一次伤害)

var burning_radius: float = 25
var is_rectangle: bool = false
var burning_memory_point: Vector2

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func do_tick_attack(delta: float) -> void:
	var distance_to_memory: float = global_position.distance_squared_to(burning_memory_point)
	
	if distance_to_memory >= pow(burning_radius * 1.5, 2):
		burning_memory_point = global_position
		add_burning_area.rpc()

func do_enter_attack() -> void:
	burning_memory_point = global_position
	
func do_enter_landing() -> void:
	add_burning_area.rpc()

@rpc("authority", "call_local")
func add_burning_area() -> void:
	var instance = BURNING_SUMMONS.instantiate()
	instance.player_id = player_id 
	instance.slot_id = slot_id
	instance.init_position = global_position
	instance.damage = burning_damage
	instance.is_rectangle = false
	instance.r_size = Vector2.ZERO
	instance.c_radius = burning_radius * (1 + attributes["SPAWN_SIZE"])
	instance.life_time = attributes["EFF_DUR"]
	
	Levels.activated_level.add_child(instance, true)
