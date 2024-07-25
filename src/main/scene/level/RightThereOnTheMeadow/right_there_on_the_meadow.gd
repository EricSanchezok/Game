extends Node2D

@onready var level_wait_timer: Timer = $LevelWaitTimer
@onready var fight_timer: Timer = $FightTimer

var current_level: int = 0:
	set(v):
		current_level = v
		level_wait_timer.start()
		for player in Game.players.values():
			player.show()
			player.state_machine.is_lock = false
			for weapon in WeaponsManager.players_weapons[player.multiplayer_id]:
				if weapon.traits.has("STATION"):
					weapon.global_position = Tools.get_random_station_position()
				weapon.show()
				weapon.state_machine.is_lock = false


func _ready() -> void:
	Game.respawn_all_players_finished.connect(_on_respawn_all_players_finished)
	
func _on_test_timer_1_timeout() -> void:
	pass

func _on_test_timer_2_timeout() -> void:
	pass
	Game.players[1].register_weapon.emit(1, 23, 0)
	Game.players[1].register_weapon.emit(1, 1, 1)
	#Game.players[1].register_weapon.emit(1, 12, 2)
	#Game.players[1].register_weapon.emit(1, 17, 3)
	#Game.players[1].register_weapon.emit(1, 33, 4)
	#Game.players[1].register_weapon.emit(1, 25, 5)
	#Game.players[1].register_weapon.emit(1, 26, 6)
	#Game.players[1].register_weapon.emit(1, 27, 7)
	

func level_up(level: int) -> void:
	match level:
		1: #第一关应该很简单，只有一种初始怪
			#EnemiesManager.register_enemy("Shade", "A", 1, 1, 5)  #Shade
			EnemiesManager.register_enemy("Slime", "D", 1, 1, 1)  #Slime
		2: #第二关多一个碰撞怪
			EnemiesManager.register_enemy("Slime", "D", 2, 2, 4)  #Slime
			EnemiesManager.register_enemy("Shade", "A", 2, 4, 3)  #Shade
		3: #第三关开始有子弹怪
			EnemiesManager.register_enemy("Slime", "D", 3, 1, 5)  #Slime
			EnemiesManager.register_enemy("Shade", "A", 3, 2, 4)  #Shade
			EnemiesManager.register_enemy("OneEyed", "C", 3, 8, 2)  #OneEyed
		4: #第四关再多一种碰撞怪
			EnemiesManager.register_enemy("Slime", "D", 4, 1, 5)  #Slime
			EnemiesManager.register_enemy("Shade", "A", 4, 2, 5)  #Shade
			EnemiesManager.register_enemy("UnicornShade", "C", 4, 4, 2)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "C", 4, 5, 2)  #OneEyed
		5: #第五关开始有冲刺怪
			EnemiesManager.register_enemy("Slime", "D", 5, 0.5, 5)  #Slime
			EnemiesManager.register_enemy("Shade", "A", 5, 2, 5)  #Shade
			EnemiesManager.register_enemy("UnicornShade", "C", 5, 2, 2)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "C", 5, 5, 2)  #OneEyed
			EnemiesManager.register_enemy("CatMonster", "B", 5, 6, 1)  #CatMonster
		6: #第六关精英怪前的一关，这关应该尽可能多怪给玩家提供钱提升自己来面对精英关卡
			EnemiesManager.register_enemy("Slime", "D", 6, 0.1, 5)  #Slime
			EnemiesManager.register_enemy("Shade", "A", 6, 1, 5)  #Shade
			EnemiesManager.register_enemy("UnicornShade", "C", 6, 1, 3)  #UnicornShade
		7: #第七关是前期的最后一关，有精英怪（暂时没有）
			EnemiesManager.register_enemy("Shade", "A", 7, 0.5, 5)  #Shade
			EnemiesManager.register_enemy("UnicornShade", "C", 7, 1, 3)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "C", 7, 3, 2)  #OneEyed
			EnemiesManager.register_enemy("CatMonster", "B", 7, 3, 2)  #CatMonster
		8: #进入中期第一关，出现怪物的变种形态，经历了打钱关和精英关之后玩家实力会有很大提升,这一关应该在难度上会有质的变化，
			EnemiesManager.register_enemy("Shade", "A", 8, 0.5, 7)  #Shade
			EnemiesManager.register_enemy("Shade", "C", 8, 2, 3)  #Shade
			EnemiesManager.register_enemy("UnicornShade", "A", 8, 0.5, 5)  #UnicornShade
			EnemiesManager.register_enemy("UnicornShade", "D", 8, 2, 4)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "C", 8, 3, 2)  #OneEyed
			EnemiesManager.register_enemy("CatMonster", "B", 8, 2, 2)  #CatMonster
			EnemiesManager.register_enemy("CatMonster", "D", 8, 5, 1)  #CatMonster
		9: #中期第二关，之后难度不会有很大提升，给玩家留有攒钱吃利息的空间
			EnemiesManager.register_enemy("Shade", "C", 9, 0.5, 5)  #Shade
			EnemiesManager.register_enemy("JumpShade", "A", 9, 1, 5)  # JumpShade
			EnemiesManager.register_enemy("UnicornShade", "D", 9, 2, 5)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "C", 9, 3, 5)  #OneEyed
			EnemiesManager.register_enemy("CatMonster", "D", 9, 3, 5)  #CatMonster
		10: #中期第三关，出现更多变种
			EnemiesManager.register_enemy("Shade", "C", 10, 0.5, 5)  #Shade
			EnemiesManager.register_enemy("JumpShade", "A", 10, 0.5, 5)  # JumpShade
			EnemiesManager.register_enemy("UnicornShade", "D", 10, 1, 5)  #UnicornShade
			EnemiesManager.register_enemy("UnicornShade", "D", 10, 3, 5)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "C", 10, 3, 5)  #OneEyed
			EnemiesManager.register_enemy("CatMonster", "D", 10, 3, 5)  #CatMonster
			EnemiesManager.register_enemy("CatMonster", "D", 10, 5, 5)  #CatMonster
		11: #中期的中期，怪物数值提升，种类增加
			EnemiesManager.register_enemy("JumpShade", "A", 11, 0.5, 5)  # JumpShade
			EnemiesManager.register_enemy("JumpShade", "B", 11, 3, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 11, 10, 5)  # BigShade
			EnemiesManager.register_enemy("UnicornShade", "D", 11, 1, 5)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "D", 11, 5, 5)  #OneEyed
			EnemiesManager.register_enemy("TriangleShade", "A", 11, 3, 5)  #TriangleShade
			EnemiesManager.register_enemy("WeaponShade", "B", 11, 5, 5)  #WeaponShade
			EnemiesManager.register_enemy("CatMonster", "D", 11, 3, 5)  #CatMonster
		12: #增加一种冲刺怪
			EnemiesManager.register_enemy("JumpShade", "A", 12, 0.3, 5)  # JumpShade
			EnemiesManager.register_enemy("JumpShade", "B", 12, 5, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 12, 7, 5)  # BigShade
			EnemiesManager.register_enemy("UnicornShade", "D", 12, 0.5, 5)  #UnicornShade
			EnemiesManager.register_enemy("OneEyed", "D", 12, 3, 5)  #OneEyed
			EnemiesManager.register_enemy("TriangleShade", "A", 12, 5, 5)  #TriangleShade
			EnemiesManager.register_enemy("WeaponShade", "B", 12, 5, 5)  #WeaponShade
			EnemiesManager.register_enemy("FatShade", "A", 12, 7, 5)  #FatShade
			EnemiesManager.register_enemy("CatMonster", "D", 12, 3, 5)  #CatMonster
		13: #第二个精英关卡前的打钱关
			EnemiesManager.register_enemy("JumpShade", "A", 13, 0.1, 5)  # JumpShade
			EnemiesManager.register_enemy("JumpShade", "B", 13, 3, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 13, 5, 5)  # BigShade
			EnemiesManager.register_enemy("UnicornShade", "D", 13, 0.2, 5)  #UnicornShade
		14: #第二个精英关
			EnemiesManager.register_enemy("JumpShade", "B", 14, 3, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 14, 5, 5)  # BigShade
			EnemiesManager.register_enemy("UnicornShade", "C", 14, 0.2, 5)  #UnicornShade
			EnemiesManager.register_enemy("TriangleShade", "A", 14, 5, 5)  #TriangleShade
			EnemiesManager.register_enemy("FatShade", "A", 14, 3, 5)  #FatShade
		15: #进入后期第一关
			EnemiesManager.register_enemy("JumpShade", "C", 15, 0.5, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 15, 3, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "A", 15, 1, 5)  # FireSkull
			EnemiesManager.register_enemy("TriangleShade", "B", 15, 3, 5)  #TriangleShade
			EnemiesManager.register_enemy("FatShade", "B", 15, 3, 5)  #FatShade
		16: #后期第二关，过度关卡
			EnemiesManager.register_enemy("JumpShade", "C", 16, 0.2, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 16, 3, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "A", 16, 0.5, 5)  # FireSkull
			EnemiesManager.register_enemy("Slime", "B", 16, 2, 5)  #Slime
			EnemiesManager.register_enemy("TriangleShade", "B", 16, 3, 5)  #TriangleShade
			EnemiesManager.register_enemy("FatShade", "B", 16, 3, 5)  #FatShade
		17: #后期第三关，过渡关卡
			EnemiesManager.register_enemy("JumpShade", "C", 17, 0.1, 5)  # JumpShade
			EnemiesManager.register_enemy("BigShade", "A", 17, 3, 5)  # BigShade
			EnemiesManager.register_enemy("BigShade", "D", 17, 10, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "A", 17, 0.5, 5)  # FireSkull
			EnemiesManager.register_enemy("Slime", "B", 17, 1, 5)  #Slime
			EnemiesManager.register_enemy("TriangleShade", "B", 17, 3, 5)  #TriangleShade
			EnemiesManager.register_enemy("FatShade", "B", 17, 3, 5)  #FatShade
		18: #后期第四关，出现更多后期怪
			EnemiesManager.register_enemy("BigShade", "A", 18, 2, 5)  # BigShade
			EnemiesManager.register_enemy("BigShade", "D", 18, 5, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "A", 18, 0.2, 5)  # FireSkull
			EnemiesManager.register_enemy("FireSkull", "C", 18, 1, 5)  # FireSkull
			EnemiesManager.register_enemy("OneEyed", "B", 18, 5, 5)  #OneEyed
			EnemiesManager.register_enemy("TriangleShade", "D", 18, 8, 5)  #TriangleShade
			EnemiesManager.register_enemy("WeaponShade", "B", 18, 10, 5)  #WeaponShade
			EnemiesManager.register_enemy("FatShade", "D", 18, 5, 5)  #FatShade
		19: #小怪回合中最难的一关
			EnemiesManager.register_enemy("BigShade", "A", 19, 1, 5)  # BigShade
			EnemiesManager.register_enemy("BigShade", "D", 19, 3, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "A", 19, 0.1, 5)  # FireSkull
			EnemiesManager.register_enemy("FireSkull", "C", 19, 0.5, 5)  # FireSkull
			EnemiesManager.register_enemy("OneEyed", "B", 19, 3, 5)  #OneEyed
			EnemiesManager.register_enemy("TriangleShade", "D", 19, 5, 5)  #TriangleShade
			EnemiesManager.register_enemy("WeaponShade", "B", 19, 6, 5)  #WeaponShade
			EnemiesManager.register_enemy("FatShade", "D", 19, 3, 5)  #FatShade
		20: #打钱关
			EnemiesManager.register_enemy("BigShade", "A", 20, 0.5, 5)  # BigShade
			EnemiesManager.register_enemy("BigShade", "D", 20, 1, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "A", 20, 0.1, 5)  # FireSkull
			EnemiesManager.register_enemy("FireSkull", "C", 20, 0.3, 5)  # FireSkull
		21: #Boss
			EnemiesManager.register_enemy("BigShade", "D", 21, 1, 5)  # BigShade
			EnemiesManager.register_enemy("FireSkull", "C", 21, 0.1, 5)  # FireSkull
			EnemiesManager.register_enemy("OneEyed", "B", 21, 1, 5)  #OneEyed
			EnemiesManager.register_enemy("TriangleShade", "D", 21, 3, 5)  #TriangleShade
			EnemiesManager.register_enemy("WeaponShade", "B", 21, 5, 5)  #WeaponShade
			EnemiesManager.register_enemy("FatShade", "D", 21, 1, 5)  #FatShade


func _on_fight_timer_timeout() -> void:
	EnemiesManager.spawn_queue.clear()
	EnemiesManager.clean_all_enemies()
	for player in Game.players.values():
		player.hide()
		player.cards_screen.show_screen()
		Game.anchor_player(player)
		player.state_machine.is_lock = true
		for weapon in WeaponsManager.players_weapons[player.multiplayer_id]:
			weapon.hide()
			weapon.state_machine.is_lock = true

func _on_respawn_all_players_finished() -> void:
	for player in Game.players.values(): 
		if not player.is_node_ready(): await player.ready
		player.status_screen.fight_timer = fight_timer
		player.cards_screen.end_button.pressed.connect(_on_end_button_pressed)
	current_level += 1

func _on_end_button_pressed() -> void:
	current_level += 1


func _on_level_wait_timer_timeout() -> void:
	level_up(current_level)
	fight_timer.start()
