extends Node

const A_NIU = preload("res://src/main/scene/role/player/ANiu/a_niu.tscn")

var players = {}

signal start_game(level: Node2D)
signal leave_game(level: Node2D)
signal respawn_all_players_finished

func _ready() -> void:
	start_game.connect(_on_start_game)
	leave_game.connect(_on_leave_game)
	
	if is_multiplayer_authority():
		add_player(1)
		
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func anchor_player(player: PlayerBase) -> bool:
	for node in get_tree().get_nodes_in_group("entry_points"):
		if get_tree().current_scene.is_ancestor_of(node):
			player.global_position = node.global_position
			return true
	return false

func add_player(multiplayer_id: int) -> void:
	var player = A_NIU.instantiate()
	
	if not anchor_player(player):
		printerr("No entry point found for player")
		return
	
	player.multiplayer_id = multiplayer_id
	player.set_multiplayer_authority(multiplayer_id)

	add_object.call_deferred(player)
	
	players[multiplayer_id] = player

func respawn_all_players() -> void:
	for multiplayer_id in players.keys():
		add_player(multiplayer_id)
	respawn_all_players_finished.emit()

func add_object(obj: Variant) -> void:
	get_tree().current_scene.add_child(obj, true)
	
func is_game_start() -> bool:
	return get_tree().current_scene.name != "Campsite"
	
func change_scene(path: String, entry_point: String = "EntryPoint") -> void:
	var tree := get_tree()
	
	tree.change_scene_to_file(path)
	await tree.tree_changed

	respawn_all_players()
	
	if is_game_start():
		start_game.emit(tree.current_scene)
	else:
		leave_game.emit(tree.current_scene)
		
func remove_player(multiplayer_id: int) -> void:
	if players.has(multiplayer_id):
		if is_instance_valid(players[multiplayer_id]):
			players[multiplayer_id].queue_free()

func disconnect_player(multiplayer_id: int) -> void:
	remove_player(multiplayer_id)
	players.erase(multiplayer_id)
			
func _on_start_game(level: Node2D) -> void:
	pass

func _on_leave_game(level: Node2D) -> void:
	pass
	
func _on_peer_connected(multiplayer_id: int) -> void:
	print("peer connected: ", multiplayer_id)

func _on_peer_disconnected(multiplayer_id: int) -> void:
	print("peer disconnected: ", multiplayer_id)
