extends SpearBase

const ICE_PICK = preload("res://src/main/scene/role/standard_weapons/weapon_11/ice_pick.tscn")

@onready var slot_1: Marker2D = $Graphics/icicle_slots/slot1
@onready var slot_2: Marker2D = $Graphics/icicle_slots/slot2
@onready var slot_3: Marker2D = $Graphics/icicle_slots/slot3

var summon_count: int = 0:
	set(v):
		if summon_count == v:
			return
		summon_count = v
		deferred_add.call_deferred(summon_count)
				
var ice_picks: Array[ProjectileBase]
@export var ice_pick_damage_ratio: float = 0.5

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)
	ice_pick_damage_ratio += 0.25

func do_tick(delta: float) -> void:
	if state_machine.current_state != State.ATTACK:
		for i in range(ice_picks.size()):
			var _ice_pick = ice_picks[i]
			if not is_instance_valid(_ice_pick):
				continue
			match i+1:
				1:
					_ice_pick.graphics.rotation = slot_1.global_rotation
					_ice_pick.global_position = slot_1.global_position
				2:
					_ice_pick.graphics.rotation = slot_2.global_rotation
					_ice_pick.global_position = slot_2.global_position
				3:
					_ice_pick.graphics.rotation = slot_3.global_rotation
					_ice_pick.global_position = slot_3.global_position
					
func do_enter_attack() -> void:
	#print("what?: ", ice_picks)
	for _ice_pick in ice_picks:
		if is_instance_valid(_ice_pick):
			_ice_pick.start_flag = true
		
	ice_picks.clear()
	summon_count = 0

func deferred_add(index: int) -> void:
	add_ice_pick.rpc(index)

@rpc("authority", "call_local")
func add_ice_pick(index: int) -> void:
	var slot: Marker2D
	match index:
		1: slot = slot_1
		2: slot = slot_2
		3: slot = slot_3
		_:
			return
		
	var instance = ICE_PICK.instantiate()
	instance.player_id = player_id
	instance.slot_id = slot_id
	instance.init_rotation = slot.global_rotation
	instance.init_position = slot.global_position
	
	instance.manual_start = true
	
	ice_picks.append(instance)

	Levels.activated_level.add_child(instance, true)


func _on_freeze_success(enemy: EnemyBase) -> void:
	summon_count = clampi(summon_count + 1, 0, 3)
