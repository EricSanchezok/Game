extends Control


var text: String = "This is a PopUp Message!":
	set(v):
		text = v
		$VBoxContainer/Label.text = text


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween_time: float = 0.5
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, tween_time).from(Vector2.ZERO)


func _on_button_pressed() -> void:
	var tween_time: float = 0.5
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, tween_time).from(Vector2.ONE)
	
	await tween.finished
	queue_free()
