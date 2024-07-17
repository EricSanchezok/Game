extends Node2D

@onready var level_spawner: MultiplayerSpawner = $LevelSpawner
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

var weapon_spawner: MultiplayerSpawner
var projectile_spawner: MultiplayerSpawner
var enemy_shoot_spawner: MultiplayerSpawner
var coin_spawner: MultiplayerSpawner
var enemy_generator: PositionGenerator

@export var playerScene: PackedScene

var activated_level: Node2D:
	set(v):
		activated_level = v
		if activated_level.name == "InitialLevel":
			return
		weapon_spawner = activated_level.get_node("WeaponSpawner")
		projectile_spawner = activated_level.get_node("ProjectileSpawner")
		enemy_shoot_spawner = activated_level.get_node("EnemyShootSpawner")
		coin_spawner = activated_level.get_node("CoinSpawner")
		enemy_generator = activated_level.get_node("EnemyGenerator")
		
var players = {}

signal spawning_level(level: Node2D)
signal spawning_player(player: PlayerBase)

func _ready() -> void:
	level_spawner.spawn_function = spawn_level
	player_spawner.spawn_function = spawn_player
	
	if is_multiplayer_authority():
		level_spawner.spawn("res://src/main/scene/level/InitialLobby/initial_level.tscn")
		player_spawner.spawn(1)
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		
		
func _on_peer_connected(multiplayer_id: int) -> void:
	if not is_multiplayer_authority():
		return
	print("peer connected: ", multiplayer_id)
	Levels.player_spawner.spawn(multiplayer_id)

func _on_peer_disconnected(multiplayer_id: int) -> void:
	if not is_multiplayer_authority():
		return
	print("peer disconnected: ", multiplayer_id)
	Levels.remove_player(multiplayer_id)
		

func spawn_level(path: String) -> Node2D:
	var level = (load(path) as PackedScene).instantiate()
	activated_level = level
	spawning_level.emit(level)
	
	return level

func remove_level() -> void:
	activated_level.queue_free()

func spawn_player(multiplayer_id: int) -> PlayerBase:
	var player = playerScene.instantiate()
		
	player.multiplayer_id = multiplayer_id
	player.set_multiplayer_authority(multiplayer_id)

	players[multiplayer_id] = player
	
	var id = multiplayer.get_unique_id()
	if id != 1:
		# 非主机
		Tools.set_player_off_title(player, false)
		if multiplayer_id != 1:
			Tools.update_player_position(player, activated_level)
	else:
		# 主机
		Tools.update_player_position(player, activated_level)
	
	spawning_player.emit(player)
	return player

func remove_player(multiplayer_id: int):
	if players.has(multiplayer_id):
		players[multiplayer_id].queue_free()
		players.erase(multiplayer_id)
	
	
func tree_string() -> String:
	return get_tree_string_pretty()
	
func show_players() -> void:
	for player in players.values():
		player.show()
		
func hide_players() -> void:
	for player in players.values():
		player.hide()
