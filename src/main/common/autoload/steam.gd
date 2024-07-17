extends Node


signal create_lobby_success
signal create_lobby_fail

signal found_lobby_success
signal found_lobby_fail

signal join_lobby_success
signal join_lobby_fail

signal leave_lobby_success

# Steam variables
var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var steam_username: String = ""


var steam_multiplayer_peer = SteamMultiplayerPeer.new()
var lobby_id: int = 0
var lobby_name: String
var lobby_password: String = ""
var lobby_members: Array = []

var lobby_list: Array = []


class LobbyFilter:
	var DistanceFilter = Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE
	var LobbyIdFilter = 0


func _init() -> void:
	# Set your game's Steam app ID here
	OS.set_environment("SteamAppId", str(steam_app_id))
	OS.set_environment("SteamGameId", str(steam_app_id))

func _ready() -> void:
	initialize_steam()

	steam_multiplayer_peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func _process(_delta: float) -> void:
	Steam.run_callbacks()

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 创建大厅 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func create_lobby(lobby_type: SteamMultiplayerPeer.LOBBY_TYPE, max_players: int = 32) -> void:
	if lobby_id != 0:
		print("[%s] is already in a lobby: [%s]" % [steam_username, lobby_id])
		return
	print("[%s] is trying to create a lobby." % steam_username)
	steam_multiplayer_peer.create_lobby(lobby_type, max_players)
	
	

func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect != 1:
		print("[%s] failed to create a lobby." % steam_username)
		create_lobby_fail.emit()
		return
		
	lobby_id = this_lobby_id

	print("[%s] has created a lobby: [%s]" % [steam_username, lobby_id])

	Steam.setLobbyJoinable(lobby_id, true)

	Steam.setLobbyData(lobby_id, "name", lobby_name)
	Steam.setLobbyData(lobby_id, "password", lobby_password)
	Steam.setLobbyData(lobby_id, "mysterious_code", "51522zzwlwlbb")

	var set_relay: bool = Steam.allowP2PPacketRelay(true)

	get_lobby_members()

	multiplayer.multiplayer_peer = steam_multiplayer_peer

	create_lobby_success.emit()


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 获取大厅 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func get_lobbies(filter: LobbyFilter=LobbyFilter.new()) -> void:
	lobby_list.clear()

	Steam.addRequestLobbyListDistanceFilter(filter.DistanceFilter)
	Steam.addRequestLobbyListStringFilter("mysterious_code", "51522zzwlwlbb", Steam.LOBBY_COMPARISON_EQUAL)

	print("[%s] is requesting a list of lobbies." % steam_username)
	Steam.requestLobbyList()

func _on_lobby_match_list(these_lobbies: Array) -> void:

	if these_lobbies.size() == 0:
		found_lobby_fail.emit()
		return

	for this_lobby in these_lobbies:

		var _lobby_name: String = Steam.getLobbyData(this_lobby, "name")
		var _lobby_password: String = Steam.getLobbyData(this_lobby, "password")

		var _num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var _max_members: int = Steam.getLobbyMemberLimit(this_lobby)

		var _info: String
		if _lobby_password != "":
			_info = "%s - %s/%s Player(s) - Password Protected" % [_lobby_name, _num_members, _max_members]
		else:
			_info = "%s - %s/%s Player(s)" % [_lobby_name, _num_members, _max_members]

		var lobby_dict = {
			"id": this_lobby,
			"name": _lobby_name,
			"password": _lobby_password,
			"num_members": _num_members,
			"max_members": _max_members,
			"info": _info
		}

		lobby_list.append(lobby_dict)

	found_lobby_success.emit()


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 加入大厅 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func join_lobby(this_lobby_id: int) -> void:
	print("[%s] is trying to join the lobby: [%s]" % [steam_username, this_lobby_id])
	
	lobby_members.clear()

	steam_multiplayer_peer.connect_lobby(this_lobby_id)


func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if this_lobby_id == lobby_id:
		return
	# If joining was successful
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		
		print("[%s] has joined the lobby: [%s]" % [steam_username, this_lobby_id])

		lobby_id = this_lobby_id

		get_lobby_members()

		multiplayer.multiplayer_peer = steam_multiplayer_peer

		join_lobby_success.emit()

	# Else it failed for some reason
	else:
		# Get the failure reason
		var fail_reason: String

		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Uh... something unexpected happened!"
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."

		print("[%s] failed to join the lobby: [%s] - %s" % [steam_username, this_lobby_id, fail_reason])

		#Reopen the lobby list
		get_lobbies()

		join_lobby_fail.emit()


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 离开大厅 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func leave_lobby() -> void:
	if lobby_id != 0:
		print("[%s] is leaving the lobby: [%s]" % [steam_username, lobby_id])
		# Send leave request to Steam
		Steam.leaveLobby(lobby_id)

		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		lobby_id = 0

		# Close session with all users
		for this_member in lobby_members:
			# Make sure this isn't your Steam ID
			if this_member['steam_id'] != steam_id:

				# Close the P2P session
				Steam.closeP2PSessionWithUser(this_member['steam_id'])

		# Clear the local lobby list
		lobby_members.clear()

		print("[%s] has left the lobby." % steam_username)

		leave_lobby_success.emit()



# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Steam 相关功能函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func get_lobby_members() -> void:
	# Clear your previous lobby list
	lobby_members.clear()

	# Get the number of members from this lobby from Steam
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)

	# Get the data of these players from Steam
	for this_member in range(0, num_of_members):
		# Get the member's Steam ID
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)

		# Get the member's Steam name
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)

		# Add them to the list
		lobby_members.append({"steam_id":member_steam_id, "steam_name":member_steam_name})


func initialize_steam() -> void:
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s" % initialize_response)

	if initialize_response['status'] > 0:
		print("Failed to initialize Steam. Shutting down. %s" % initialize_response)
		get_tree().quit()

	# Gather additional data
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()

	lobby_name = "%s's Lobby" % steam_username

	print(">>>>>>>>>>>>>>>>>>>>>>>>>STEAM STATUS>>>>>>>>>>>>>>>>>>>>>>>>>")
	print("Steam is running on Steam Deck: %s" % is_on_steam_deck)
	print("Steam is online: %s" % is_online)
	print("Steam is owned: %s" % is_owned)
	print("Steam ID: %s" % steam_id)
	print("Steam Username: %s" % steam_username)
	print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")


