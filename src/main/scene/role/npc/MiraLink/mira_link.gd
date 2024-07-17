extends Npc

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var e_net_multiplayer_peer = ENetMultiplayerPeer.new() 

enum Progress {
	HOST_OR_JOIN,
	MODE_SELECTION,
	JOIN_WHICH,
	CONFIRM_LEAVE,
}
var progress

var multiplayer_mode

func _ready() -> void:
	super()
	animation_player.play("idle")
	
	DialogBox.button_1.pressed.connect(_on_button_1_pressed)
	DialogBox.button_2.pressed.connect(_on_button_2_pressed)
	DialogBox.confirm_button.pressed.connect(_on_confirm_button_pressed)
	
	DialogBox.interact_pressed.connect(_on_interact_pressed)
	
	GlobalSteam.create_lobby_success.connect(_on_create_lobby_success)
	GlobalSteam.create_lobby_fail.connect(_on_create_lobby_fail)
	
	
	GlobalSteam.join_lobby_success.connect(_on_join_lobby_success)
	GlobalSteam.join_lobby_fail.connect(_on_join_lobby_fail)
	
func host_or_join() -> void:
	DialogBox.show_options("Host", "Join")
	progress = Progress.HOST_OR_JOIN
	
func mode_selection() -> void:
	DialogBox.show_options("Ether Stream", "Arcane Network")
	progress = Progress.MODE_SELECTION
	
func join_which() -> void:
	DialogBox.show_options("Ether Stream", "Arcane Network")
	progress = Progress.JOIN_WHICH
	
func confirm_leave() -> void:
	DialogBox.show_options("Confirm", "Cancel")
	progress = Progress.CONFIRM_LEAVE
	
	
func create_lobby() -> void:
	if multiplayer_mode == "Ether Stream":
		GlobalSteam.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, 4)
	if multiplayer_mode == "Arcane Network":
		var error = e_net_multiplayer_peer.create_server(9980)
		if error != OK:
			_on_create_lobby_fail()
			return
		multiplayer.multiplayer_peer = e_net_multiplayer_peer
		_on_create_lobby_success()

func get_random_dialogue(type: int):
	var dialogues: Array
	match type:
		0:
			dialogues = [
				"The gates to the void are open for you. Dare to explore the unknown?",
				"The dark corridors connecting the realms are calling. Are you ready to step into them?",
				"Summoning adventurers from other worlds is not without risks. Are you sure you want to continue?",
				"The dimensional gates are about to open. Are you ready to embrace this power?",
				"Dark magic will connect all corners. Do you confirm to perform this ritual?"
			]
		1:
			dialogues = [
				"The dimensional gates are open, and adventurers from other realms will now converge.",
				"The powers of darkness have linked us. Are you prepared to face the challenges?",
				"The ritual is complete, ancient powers now gather here."
			]
		2:
			dialogues = [
				"The dark forces did not respond to our summons, and the dimensional gates remain closed.",
				"The ritual has failed, and the connection to other realms could not be established.",
				"Our power was insufficient to shake the walls of dimensions. We need more preparation."
			]
		3:
			dialogues = [
				"The ancient gates did not open; the void has not yet welcomed you.",
				"No path was found in the dark echoes; attempt to find the crevice anew.",
				"The ritual to traverse between worlds was thwarted by an ancient curse; the powers must gather once more.",
				"The bridge to forgotten realms has collapsed; tread carefully before venturing the unknown paths again.",
				"The call to the void went unanswered; the portals within the shadows remain closed."
			]

	var random_index = randi() % dialogues.size()
	return dialogues[random_index]
	

func _on_interactable_interacted(player: PlayerBase) -> void:
	$AudioStreamPlayer2D.play()
	if not GlobalVars.is_in_lobby:
		DialogBox.show_dialog_box([
			{avatar="MIRA_LINK", text=get_random_dialogue(0), callable=null},
			{avatar="MIRA_LINK", text="Shall you be the master to forge new portals, or a wanderer who steps through pre-opened gates?", callable=Callable(self, "host_or_join")}
		])
	else:
		if multiplayer_mode == "Ether Stream":
			var id_string: String = "Guard this key [%s], let it not fall into mundane hands." % GlobalSteam.lobby_id
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text=id_string, callable=null},
				{avatar="MIRA_LINK", text="Shall this gate be sealed, cutting off the path through the void?", callable=Callable(self, "confirm_leave")}
			])
		if multiplayer_mode == "Arcane Network":
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Shall this gate be sealed, cutting off the path through the void?", callable=Callable(self, "confirm_leave")}
			])

	DialogBox.player = player
	player.lock_input = true
	

	
func _on_button_1_pressed() -> void:
	match progress:
		Progress.HOST_OR_JOIN:
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Will you summon distant souls via the Ether Stream, or capture nearby spirits through the Arcane Network?", callable=Callable(self, "mode_selection")}
			])
		
		Progress.MODE_SELECTION:
			multiplayer_mode = "Ether Stream"
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Waiting......", callable=Callable(self, "create_lobby")}
			])
			#show_magic()
		
		Progress.JOIN_WHICH:
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Enter Your Key", callable=null}
			])
			DialogBox.show_text_edit()
			
		Progress.CONFIRM_LEAVE:
			if multiplayer_mode == "Ether Stream":
				GlobalSteam.leave_lobby()
			if multiplayer_mode == "Arcane Network":
				multiplayer.multiplayer_peer.close()
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="See You......", callable=null}
			])
			#hide_magic()
			GlobalVars.is_in_lobby = false
				

func _on_button_2_pressed() -> void:
	match progress:
		Progress.HOST_OR_JOIN:
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Do you wish to explore distant worlds via the Ether Stream, or discover local mysteries with the Arcane Network?", callable=join_which},
			])
			
		Progress.MODE_SELECTION:
			multiplayer_mode = "Arcane Network"
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Waiting......", callable=Callable(self, "create_lobby")}
			])
			#show_magic()
			
		Progress.JOIN_WHICH:
			DialogBox.show_dialog_box([
				{avatar="MIRA_LINK", text="Waiting......", callable=null}
			])
			GameCanvasLayer.enter_transition()
			await GameCanvasLayer.tween_trans.finished
			var error = e_net_multiplayer_peer.create_client("127.0.0.1", 9980)
			if error != OK:
				_on_join_lobby_fail()
			else:
				multiplayer.multiplayer_peer = e_net_multiplayer_peer
				_on_join_lobby_success()

		Progress.CONFIRM_LEAVE:
				DialogBox.show_dialog_box([
					{avatar="MIRA_LINK", text="Bye......", callable=null},
				])
			
	
func _on_create_lobby_success() -> void:
	if multiplayer_mode == "Ether Stream":
		var id_string: String = "Thy secret sigil is engraved, the key to connect the void: [%s]. " % str(GlobalSteam.lobby_id)
		DialogBox.show_dialog_box([
			{avatar="MIRA_LINK", text=get_random_dialogue(1), callable=null},
			{avatar="MIRA_LINK", text=id_string, callable=null},
		])
		
	if multiplayer_mode == "Arcane Network":
		DialogBox.show_dialog_box([
			{avatar="MIRA_LINK", text=get_random_dialogue(1), callable=null},
		])

	DialogBox.is_callable_finished = true
	GlobalVars.is_in_lobby = true
	
func _on_create_lobby_fail() -> void:
	DialogBox.show_dialog_box([
		{avatar="MIRA_LINK", text=get_random_dialogue(2), callable=null},
	])
	#hide_magic()
	DialogBox.is_callable_finished = true
	GlobalVars.is_in_lobby = false
	
func _on_join_lobby_success() -> void:
	#show_magic()
	DialogBox.hide_screen()
	Levels.remove_level()
	Levels.remove_player(1)
	GameCanvasLayer.leave_transition()
	
func _on_join_lobby_fail() -> void:
	#hide_magic()
	DialogBox.show_dialog_box([
		{avatar="MIRA_LINK", text=get_random_dialogue(3), callable=null},
	])
	GameCanvasLayer.leave_transition()
	
func _on_interact_pressed() -> void:
	$AudioStreamPlayer2D.play()

func _on_confirm_button_pressed() -> void:
	if progress == Progress.JOIN_WHICH:
		GlobalSteam.join_lobby(int(DialogBox.text_edit.text))
		DialogBox.show_dialog_box([
			{avatar="MIRA_LINK", text="Joining......", callable=null}
		])
		GameCanvasLayer.enter_transition()
