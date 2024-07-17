extends TextureRect


var my_mode: String

var my_type
var my_element

func _ready() -> void:
	texture = texture.duplicate()
	var x
	var y
	var width = 16
	var height = 16

	if my_mode == "TYPE":
		y = 0
		x = 16 * my_type
		
	elif my_mode == "ELEMENT":
		y = 48
		x = 16 * my_element
		
	var rect = Rect2(x, y, width, height)
	texture.region = rect
		
