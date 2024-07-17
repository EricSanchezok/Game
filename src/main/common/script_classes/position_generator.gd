class_name PositionGenerator
extends Area2D

var spawn_shapes = []  # 创建一个数组来存储找到的 SpawnShape2D 节点

func _ready() -> void:
	for child in get_children():  # 遍历当前节点的所有子节点
		if child.is_in_group("SpawnShape"):
			spawn_shapes.append(child)  # 如果是，添加到数组中
			
func get_random_position() -> Vector2:
	'''
	从所有 CollisionShape2D 节点中随机选择一个，然后在该形状内生成一个随机位置。
	
	return: 随机位置
	'''
	var spawn_shape = get_random_shape()
	if spawn_shape:
		var pos = get_random_postion_in_shape(spawn_shape)
		return pos
	else:
		printerr("No SpawnShape2D nodes found")
		return Vector2.ZERO

func get_random_shape() -> SpawnShape2D:
	'''
	从所有 SpawnShape2D 节点中随机选择一个，概率与其 "probability" 属性成正比。
	
	return: 随机选择的 SpawnShape2D 节点
	'''
	var total_probability = 0
	for shape in spawn_shapes:
		total_probability += shape.probability  # 计算所有 shape 的概率总和

	if total_probability == 0:  # 避免除以零的错误
		return null

	var random_pick = randf() * total_probability  # 在0到总概率之间生成一个随机数

	var cumulative_probability = 0.0
	for shape in spawn_shapes:
		cumulative_probability += shape.probability
		if random_pick <= cumulative_probability:  # 检查随机数落在哪个区间
			return shape

	return null  # 如果所有概率加起来没有达到随机数（理论上不应发生），返回 null

func get_random_postion_in_shape(spawn_shape: SpawnShape2D) -> Vector2:
	'''
	生成一个在给定 SpawnShape2D 节点内的随机位置。
	该函数假设 SpawnShape2D 节点是 CircleShape2D 或 RectangleShape2D 类型。
	
	collision_shape: SpawnShape2D 节点
	return: 随机位置
	'''
	var shape = spawn_shape.shape
	var pos = Vector2.ZERO
	if shape is CircleShape2D:
		var circle = shape as CircleShape2D
		var radius = randf() * circle.radius
		var angle = randf() * 2 * PI
		pos = Vector2(cos(angle), sin(angle)) * radius + spawn_shape.global_position
	elif shape is RectangleShape2D:
		var rect = shape as RectangleShape2D
		var x = randf_range(-0.5, 0.5) * rect.size.x
		var y = randf_range(-0.5, 0.5) * rect.size.y
		pos = Vector2(x, y) + spawn_shape.global_position
	else:
		printerr("Shape type not supported")
	return pos
