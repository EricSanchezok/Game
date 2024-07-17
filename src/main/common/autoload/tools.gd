extends Node

const POP_UP_MESSAGE = preload("res://src/main/scene/ui/pop_up_message.tscn")

func _ready() -> void:
	pass

func merge_dictionaries(dict1: Dictionary, dict2: Dictionary) -> Dictionary:
	var merged_dict = dict1.duplicate()  # 创建 dict1 的副本
	for key in dict2.keys():
		merged_dict[key] = dict2[key]  # 将 dict2 的键值对添加到 merged_dict
	return merged_dict
	
func is_host() -> bool:
	return multiplayer.multiplayer_peer.get_unique_id() == 1

func create_pop_up_message(text: String) -> void:
	var instance = POP_UP_MESSAGE.instantiate()
	instance.text = text
	get_tree().root.add_child(instance)

func map_value(value, from_min, from_max, to_min, to_max):
	# 首先计算值在原始范围内的相对位置
	var t = (value - from_min) / (from_max - from_min)
	
	# 使用这个相对位置来计算目标范围内的新值
	var mapped_value = to_min + t * (to_max - to_min)
	
	# 因为目标是整数，所以需要四舍五入
	return round(mapped_value)
	
func switch_on(current: bool, before: bool) -> bool:
	if current and not before:
		return true
	return false
	
func switch_off(current: bool, before: bool) -> bool:
	if not current and before:
		return true
	return false
	
func my_id() -> int:
	return multiplayer.multiplayer_peer.get_unique_id()
	
func msg(s: String) -> void:
	print("id-" + str(my_id()) + ": " + s)
	
func my_player() -> PlayerBase:
	return Game.players[my_id()]
	
func my_weapons() -> Array:
	return WeaponsManager.players_weapons[my_id()]

func my_target_weapons(_trait: String) -> Array:
	var weapons = []
	for weapon in my_weapons():
		if _trait in weapon.traits:
			weapons.append(weapon)
	return weapons

func my_target_weapon_id_weapons(target_id: int) -> Array:
	var weapons = []
	for weapon in my_weapons():
		if weapon.weapon_id == target_id:
			weapons.append(weapon)	
	return weapons

func my_target_weapon_id_min_slot_id_weapon(target_id: int) -> WeaponBase:
	var weapons = my_target_weapon_id_weapons(target_id)
	var min_slot_id_weapon = weapons[0]
	for weapon in weapons:
		if weapon.slot_id < min_slot_id_weapon.slot_id:
			min_slot_id_weapon = weapon
	return min_slot_id_weapon
	
func my_target_weapon_id_max_level_weapon(target_id: int) -> WeaponBase:
	var weapons = my_target_weapon_id_weapons(target_id)
	var max_level_weapon = weapons[0]
	for weapon in weapons:
		if weapon.weapon_level > max_level_weapon.weapon_level:
			max_level_weapon = weapon
	return max_level_weapon
	
func check_all_target_weapon_id_weapons_same_level(target_id: int) -> bool:
	var weapons = Tools.my_target_weapon_id_weapons(target_id)
	for a_weapon in weapons:
		for b_weapon in weapons:
			if a_weapon.weapon_level != b_weapon.weapon_level:
				return false
	return true
	
func get_logic_general_weapon(target_id: int) -> WeaponBase:
	if check_all_target_weapon_id_weapons_same_level(target_id):
		return my_target_weapon_id_min_slot_id_weapon(target_id)
	else:
		return my_target_weapon_id_max_level_weapon(target_id)

func check_target_weapon_exist(weapon_id: int) -> bool:
	for weapon in my_weapons():
		if weapon.weapon_id == weapon_id:
			return true
	return false

@rpc("any_peer", "call_local")
func change_scene(path: String) -> void:
	var tree := get_tree()
	tree.change_scene_to_file(path)
	await tree.process_frame

@rpc("any_peer", "call_local")
func reload_current_scene():
	var current_scene_path = get_tree().current_scene.filename  # 获取当前场景的路径
	change_scene(current_scene_path)  # 重新加载当前场景

func are_angles_close(angle1: float, angle2: float, tolerance: float = 0.1) -> bool:
	'''
	判断两个角度是否接近

	:param angle1: 角度1
	:param angle2: 角度2
	:param tolerance: 容忍度
	:return: 是否接近
	'''
	var difference = fmod(angle1 - angle2, 2 * PI) # 计算两个角度的差值并使用2π进行模运算
	# 将差值调整到[-π, π]范围内
	if difference > PI:
		difference -= 2 * PI
	elif difference < -PI:
		difference += 2 * PI

	# 判断调整后的差值是否在容忍度范围内
	return abs(difference) <= tolerance

func get_player(player_id: int) -> PlayerBase:
	return Game.players[player_id]

func get_weapon(player_id: int, slot_id: int) -> WeaponBase:
	var weapons = WeaponsManager.players_weapons[player_id]
	for weapon in weapons:
		if weapon.slot_id == slot_id:
			return weapon
	return null

func get_random_station_position() -> Vector2:
	return Game.current_level.get_node("StationAreas").get_random_position()
	
func get_random_enemy() -> EnemyBase:
	if EnemiesManager.enemies.size() > 0:
		return EnemiesManager.enemies.pick_random()
	else:
		return null
		
func has_enemy() -> bool:
	return EnemiesManager.enemies.size() > 0

func is_success(success_rate: float) -> bool:
	'''
	根据成功率判断是否成功

	:param success_rate: 成功率 0-1
	:return: 是否成功
	'''
	return randf() <= success_rate
	
func linear_generate_points(start: Vector2, end: Vector2, n: int) -> Array:
	var points = []
	for i in range(n):
		var t = i / float(n - 1)  # 计算当前步的插值参数
		var point = start.lerp(end, t)  # 计算插值点
		points.append(point)
	return points
	
func find_most_similar_tscn(filenames, folder_name):
	'''
	查找最相似的tscn文件

	:param filenames: 文件名列表
	:param folder_name: 文件夹名
	:return: 最相似的文件名
	'''
	var best_match = ""
	var lowest_distance = INF  # 初始设置为无限大
	var normalized_folder_name = folder_name.replace("'", "").replace(" ", "_").to_lower()
	for filename in filenames:
		if filename.ends_with(".tscn"):
			var normalized_filename = filename.replace("'", "").replace(" ", "_").to_lower()
			var distance = levenshtein(normalized_folder_name, normalized_filename)
			if distance < lowest_distance:
				lowest_distance = distance
				best_match = filename
	#print("文件夹名： ", folder_name, " 匹配的文件名：", best_match)
	return best_match
	
func levenshtein(a: String, b: String) -> int:
	'''
	计算两个字符串之间的编辑距离

	:param a: 字符串a
	:param b: 字符串b
	:return: 编辑距离
	'''
	var costs = []
	for i in range(a.length() + 1):
		costs.append([])
		for j in range(b.length() + 1):
			if i == 0:
				costs[i].append(j)
			elif j == 0:
				costs[i].append(i)
			else:
				costs[i].append(0)
	for i in range(1, a.length() + 1):
		for j in range(1, b.length() + 1):
			var cost = 0 if a[i - 1] == b[j - 1] else 1
			costs[i][j] = min(costs[i - 1][j] + 1, costs[i][j - 1] + 1, costs[i - 1][j - 1] + cost)
	return costs[a.length()][b.length()]

func print_weapon_pool_item(weapon_pool_item: Dictionary) -> void:
	'''
	打印武器池中的武器信息

	:param weapon_pool_item: 武器池中的武器
	:return: None
	'''
	print("id:", weapon_pool_item["id"])
	print("weapon_name:", weapon_pool_item["weapon_name"])
	print("resource_path:", weapon_pool_item["resource_path"])
	print("icon_path:", weapon_pool_item["icon_path"])
	print("price:", weapon_pool_item["price"])
	print("star_rating:", weapon_pool_item["star_rating"])
	print("current_quantity:", weapon_pool_item["current_quantity"])
	print("max_quantity:", weapon_pool_item["max_quantity"])
	print("weapon_class:", weapon_pool_item["weapon_class"])
	print("weapon_origin:", weapon_pool_item["weapon_origin"])

func print_weapon_pool(_weapon_pool: Array) -> void:
	'''
	打印武器池中的所有武器信息

	:return: None
	'''
	print(">>>>>>>>>>>>>>>>>>>武器池信息>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	for weapon_pool_item in _weapon_pool:
		print(">>>>>>>>>>>>>>>>>")
		print_weapon_pool_item(weapon_pool_item)

func print_weapon_pool_counter(_weapon_pool: Array) -> void:
	'''
	打印武器池中的武器数量

	:return: None
	'''
	print(">>>>>>>>>>>>>>>>>>>武器池数量>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
	for weapon_pool_item in _weapon_pool:
		print(weapon_pool_item.weapon_name, "    数量：", weapon_pool_item.current_quantity, "    最大数量：", weapon_pool_item.max_quantity)


func apply_spawn_object_size_multiplier(target: Variant) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(target, "scale", target.scale * (1 + target.attributes["SPAWN_SIZE"]), 0.2)
	
func is_initial_level(level: Node2D) -> bool:
	return level.name == "InitialLevel"
