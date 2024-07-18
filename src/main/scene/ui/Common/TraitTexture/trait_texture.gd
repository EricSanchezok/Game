extends TextureRect

var types = ["SWORD", "SHIELD", "AXE", "SPEAR", "DAGGER", "BOW", "STAFF", "SCROLL", "FIREARM", "STATION", "BOOK", "BOOMERANG"]
var elements = ["FIRE", "FROST", "LIGHTING", "EARTH", "TOXIN", "NATURE", "DIVINITY", "DEMON"]

var my_trait: String

func _ready() -> void:
	texture = texture.duplicate()
	var x
	var y
	var width = 16
	var height = 16

	if my_trait in types:
		y = 0
		x = 16 * types.find(my_trait)
		
	elif my_trait in elements:
		y = 48
		x = 16 * elements.find(my_trait)
		
	var rect = Rect2(x, y, width, height)
	texture.region = rect
		
