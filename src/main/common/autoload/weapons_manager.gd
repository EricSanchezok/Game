extends Node

var weapon_data_base: Array = [] # 武器基础数据库

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 关卡初始化变量 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
var weapon_pool = [] # 武器池
var players_weapons = {} # 玩家武器字典

var draw_request_queue = [] # 抽取请求队列

func _ready():
	# 加载武器基础数据
	load_weapon_data_base("res://src/main/WeaponDataBase.xlsx")
	Game.start_game.connect(_on_start_game)

	set_process(is_multiplayer_authority())

	
func _process(delta: float) -> void:
	while draw_request_queue.size() > 0:
		var request = draw_request_queue.pop_front()
		var player_id = request["player_id"]
		var player_level = request["player_level"]
		var weapon_pool_item = draw_weapon(player_level)
		add_draw_result.rpc(player_id, weapon_pool_item)
	
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 功能函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func upgrade_weapon(player: PlayerBase, slot_index: int, level: int) -> void:
	'''
	升级武器

	:param player: 玩家
	:param slot_index: 武器槽索引
	:param level: 升级等级
	:return: None
	'''
	
	for weapon in players_weapons[player]:
		if weapon.slot_index == slot_index:
			weapon.weapon_level = level
			break

@rpc("authority", "call_local")
func add_draw_result(player_id: int, weapon_pool_item: Dictionary) -> void:
	'''
	添加抽取结果

	:param player_id: 玩家id
	:param weapon: 武器
	:return: None
	'''
	var player = Tools.get_player(player_id)
	player.draw_result_queue.append(weapon_pool_item)

@rpc("any_peer", "call_local")
func request_draw_weapon(player_id: int, player_level: int) -> void:
	var request = {
		"player_id": player_id,
		"player_level": player_level
	}
	draw_request_queue.append(request)

func draw_weapon(player_level: int) -> Dictionary:
	'''
	抽取武器

	:param player_level: 玩家等级
	:return: 抽取的武器
	'''
	# 根据玩家等级确定星级概率
	var star_probs = map_level_to_star_probs(player_level)
	# 过滤可抽取的武器
	var available_weapons = []
	for item in weapon_pool:
		if item["current_quantity"] > 0 and star_probs.has(item["star_rating"]):
			if is_weapon_locked(item["weapon_id"]):
				available_weapons.append(item)

	# 如果没有可抽取的武器，返回null
	if available_weapons.size() == 0:
		printerr("no available weapons!")
		return {}

	# 根据星级概率抽取武器
	var total_prob = 0.0
	var cumulative_probs = []
	for item in available_weapons:
		var prob = star_probs[item["star_rating"]]
		total_prob += prob
		cumulative_probs.append(total_prob)

	var rand = randf() * total_prob
	for i in range(cumulative_probs.size()):
		if rand < cumulative_probs[i]:
			var chosen_weapon = available_weapons[i]
			weapon_pool_change(chosen_weapon["weapon_id"], -1)
			return chosen_weapon

	return {}

func map_level_to_star_probs(player_level: int) -> Dictionary:
	'''
	根据玩家等级映射星级概率

	:param player_level: 玩家等级
	:return: 星级概率
	'''
	var star_probs = {}
	if player_level == 1 or player_level == 2:
		star_probs = {1: 1.0}
	elif player_level == 3:
		star_probs = {1: 0.75, 2: 0.25}
	elif player_level == 4:
		star_probs = {1: 0.55, 2: 0.30, 3: 0.15}
	elif player_level == 5:
		star_probs = {1: 0.45, 2: 0.33, 3: 0.20, 4: 0.02}
	elif player_level == 6:
		star_probs = {1: 0.30, 2: 0.40, 3: 0.25, 4: 0.05}
	elif player_level == 7:
		star_probs = {1: 0.19, 2: 0.30, 3: 0.40, 4: 0.10, 5: 0.01}
	elif player_level == 8:
		star_probs = {1: 0.18, 2: 0.25, 3: 0.32, 4: 0.22, 5: 0.03}
	elif player_level == 9:
		star_probs = {1: 0.10, 2: 0.20, 3: 0.25, 4: 0.35, 5: 0.10}
	elif player_level == 10:
		star_probs = {1: 0.05, 2: 0.10, 3: 0.20, 4: 0.40, 5: 0.25}
	elif player_level >= 11:
		star_probs = {1: 0.01, 2: 0.02, 3: 0.12, 4: 0.50, 5: 0.35}

	return star_probs

func recycle_weapon(weapon_pool_item: Dictionary, number: int) -> void:
	'''
	回收武器

	:param weapon_pool_item: 需要回收的武器
	:param number: 回收数量
	:return: None
	'''
	weapon_pool_change(weapon_pool_item["id"], number)

func weapon_pool_change(weapon_id: int, number: int) -> void:
	'''
	武器池数量变化

	:param weapon_id: 武器id
	:param number: 变化数量
	:return: None
	'''
	for item in weapon_pool:
		if item["weapon_id"] == weapon_id:
			item.current_quantity += number
			break

func create_weapon_pool() -> void:
	'''
	创建武器池
	'''
	weapon_pool.clear()

	for weapon_data in weapon_data_base:
		var weapon_pool_item = {}
		weapon_pool_item["weapon_id"] = int(weapon_data["weapon_id"])
		weapon_pool_item["weapon_name"] = weapon_data["weapon_name"]
		weapon_pool_item["resource_path"] = weapon_data["resource_path"]
		weapon_pool_item["icon_path"] = weapon_data["icon_path"]
		
		weapon_pool_item["star_rating"] = int(weapon_data["star_rating"])
		weapon_pool_item["price"] = weapon_data["price"]

		var details = allocate_weapon_details(weapon_pool_item["price"])
		
		weapon_pool_item["max_quantity"] = int(details["quantity"]) if weapon_data["max_quantity"] == -1 else int(weapon_data["max_quantity"])
		weapon_pool_item["current_quantity"] = int(weapon_pool_item["max_quantity"])

		weapon_pool.append(weapon_pool_item)

func load_weapon_data_base(path: String) -> void:
	'''
	加载武器基础数据

	:param path: 武器基础数据表路径
	:return: None
	'''

	var excel = ExcelFile.open_file(path)
	var workbook = excel.get_workbook()

	var sheet = workbook.get_sheet(0)
	var table_data = sheet.get_table_data()
	for row_index in range(2, 52):
		var data = {}
		for j in range(table_data[1].size()):
			data[table_data[1][j+1]] = table_data[row_index][j+1]
		weapon_data_base.append(data)
		
func get_weapon_pool_item(weapon_id: int) -> Dictionary:
	'''
	根据id获取武器池中的武器

	:param weapon_id: 武器id
	:return: 武器
	'''
	for item in weapon_pool:
		if item["weapon_id"] == weapon_id:
			return item
	return {}

func get_weapon_data_base(weapon_id: int) -> Dictionary:
	'''
	根据id获取武器基础数据

	:param weapon_id: 武器id
	:return: 武器基础数据
	'''
	for item in weapon_data_base:
		if item["weapon_id"] == weapon_id:
			return item
	return {}

func get_traits(weapon_id: int) -> Array:
	var weapon_data = get_weapon_data_base(weapon_id)

	var types_string_array = weapon_data["types"].split("/")
	var elements_string_array = weapon_data["elements"].split("/")
	
	var traits = []

	for _string in types_string_array:
		traits.append(_string)
	for _string in elements_string_array:
		traits.append(_string)

	return traits
	
func is_weapon_unique(player_id: int, weapon: WeaponBase) -> bool:
	'''
	判断武器是否唯一

	:param player: 玩家
	:param weapon: 武器
	:return: 是否唯一
	'''
	for _weapon in players_weapons[player_id]:
		if _weapon == weapon:
			continue
		if weapon.equals(_weapon):
			return false
	return true

func allocate_weapon_details(price: float) -> Dictionary:
	'''
	根据传入的价格，返回对应卡池中的数量和星级

	:param price: 武器价格
	:return: 包含武器数量和星级的字典
	'''
	var details = {
		"quantity": -1
	}
	
	if price >= 0 and price < 50:
		details["quantity"] = 22
	elif price >= 50 and price < 100:
		details["quantity"] = 20
	elif price >= 100 and price < 150:
		details["quantity"] = 17
	elif price >= 150 and price < 200:
		details["quantity"] = 10
	elif price >= 200 and price < 250:
		details["quantity"] = 9

	return details

# 判断武器是否被锁定的函数
func is_weapon_locked(weapon_id: int) -> bool:
	if GlobalVars.weapon_locks.has(weapon_id):
		return GlobalVars.weapon_locks[weapon_id]
	else:
		print("Invalid weapon ID:", weapon_id)
		return false # 如果武器ID无效，返回false

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 回调函数 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
func _on_start_game(level: Node2D) -> void:
	# 初始化玩家武器字典
	players_weapons.clear()
	for player in Game.players.values():
		player.register_weapon.connect(_on_player_register_weapon)
		player.unregister_weapon.connect(_on_player_unregister_weapon)
		players_weapons[player.multiplayer_id] = []
	
	create_weapon_pool()

	draw_request_queue.clear()


func _on_player_register_weapon(player_id: int, weapon_id: int, slot_id: int) -> void:
	_register_weapon.rpc(player_id, weapon_id, slot_id)
	
	
@rpc("any_peer", "call_local")
func _register_weapon(player_id: int, weapon_id: int, slot_id: int) -> void:
	'''
	注册武器
	
	:param player: 玩家
	:param weapon_name: 武器名
	:param slot_index: 武器槽索引
	:return: None
	'''

	var weapon_data = get_weapon_pool_item(weapon_id)
	
	var resource_path = weapon_data["resource_path"]
	
	var instance: WeaponBase = (load(resource_path) as PackedScene).instantiate()
	
	instance.player_id = player_id
	instance.weapon_id = weapon_id
	instance.slot_id = slot_id
	
	players_weapons[player_id].append(instance)
	
	Game.add_object(instance)

func _on_player_unregister_weapon(player_id: int, slot_id: int) -> void:
	_unregister_weapon.rpc(player_id, slot_id)

@rpc("any_peer", "call_local")
func _unregister_weapon(player_id: int, slot_id: int) -> void:
	'''
	注销武器

	:param player: 玩家
	:param slot_index: 武器槽索引
	:return: None
	'''
	var weapon: WeaponBase = Tools.get_weapon(player_id, slot_id)
	players_weapons[player_id].erase(weapon)
	
	weapon.deregistered.emit(weapon)

