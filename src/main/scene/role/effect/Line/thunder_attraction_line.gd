extends Sprite2D

var length: float = 0.0:
	set(v):
		length = v
		if not is_node_ready(): await ready
		offset = Vector2(length / 2, 0)
		region_rect = Rect2(0, 0, length, 32)
		
		
