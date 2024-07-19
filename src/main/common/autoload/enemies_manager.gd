extends Node

const BIG_SHADE = preload("res://src/main/scene/role/enemy/BigShade/big_shade.tscn")
const CAT_MONSTER = preload("res://src/main/scene/role/enemy/CatMonster/cat_monster.tscn")
const FAT_SHADE = preload("res://src/main/scene/role/enemy/FatShade/fat_shade.tscn")
const FIRE_SKULL = preload("res://src/main/scene/role/enemy/FireSkull/fire_skull.tscn")
const JUMP_SHADE = preload("res://src/main/scene/role/enemy/JumpShade/jump_shade.tscn")
const ONE_EYED = preload("res://src/main/scene/role/enemy/OneEyed/one_eyed.tscn")
const SHADE = preload("res://src/main/scene/role/enemy/Shade/shade.tscn")
const SLIME = preload("res://src/main/scene/role/enemy/Slime/slime.tscn")
const TRIANGLE_SHADE = preload("res://src/main/scene/role/enemy/TriangleShade/triangle_shade.tscn")
const WEAPON_SHADE = preload("res://src/main/scene/role/enemy/WeaponShade/weapon_shade.tscn")

var enemies: Array[EnemyBase]
var enemy_areas: PositionGenerator
var spawn_queue: Array = []

func _ready() -> void:
	Game.start_game.connect(_on_start_game)
	Game.leave_game.connect(_on_leave_game)
	
func _process(delta: float) -> void:
	for spawn_info in spawn_queue:
		spawn_info["time_left"] -= delta
		if spawn_info["time_left"] <= 0:
			for i in range(spawn_info["number"]):

				var instance: EnemyBase = get_enemy(spawn_info["enemy_name"]).instantiate()
				instance.enemy_type = spawn_info["enemy_type"]
				instance.progress = spawn_info["progress"]
		
				instance.global_position = enemy_areas.get_random_position()
				instance.enemy_die.connect(_on_enemy_die)
		
				enemies.append(instance)
				
				Game.add_object(instance)
			spawn_info["time_left"] = spawn_info["duration"] #重置时间
			
func register_enemy(enemy_name: String, enemy_type: String, progress: int, duration: float, number: int) -> void:
	var spawn_info = {
		"enemy_name": enemy_name,
		"enemy_type": enemy_type,
		"progress": progress,
		"duration": duration,
		"time_left": duration,
		"number": number,
	}
	spawn_queue.append(spawn_info)
	
func clean_all_enemies() -> void:
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()

func get_enemy(enemy_name: String) -> PackedScene:
	match enemy_name:
		"BigShade":
			return BIG_SHADE
		"CatMonster":
			return CAT_MONSTER
		"FatShade":
			return FAT_SHADE
		"FireSkull":
			return FIRE_SKULL
		"JumpShade":
			return JUMP_SHADE
		"OneEyed":
			return ONE_EYED
		"Shade":
			return SHADE
		"Slime":
			return SLIME
		"TriangleShade":
			return TRIANGLE_SHADE
		"WeaponShade":
			return WEAPON_SHADE
		_:
			return null
	
func _on_start_game(level: Node2D) -> void:
	for node in get_tree().get_nodes_in_group("EnemyAreas"):
		if level.is_ancestor_of(node):
			enemy_areas = node
			break
	set_process(true)
	
func _on_leave_game(level: Node2D) -> void:
	set_process(false)

func _on_enemy_die(enemy: EnemyBase) -> void:
	enemies.erase(enemy)
