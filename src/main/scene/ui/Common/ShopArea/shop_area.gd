extends Control

@onready var panel: Panel = $Panel

@export var area_type: Card.AreaType

var tween_show: Tween

func _ready() -> void:
	panel.hide()
	panel.modulate.a = 0.0
	
func show_screen() -> void:
	if tween_show and tween_show.is_running():
		tween_show.kill()
	tween_show = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_show.tween_property(panel, "modulate:a", 1.0, 0.5)
	panel.show()
	
func hide_screen() -> void:
	if tween_show and tween_show.is_running():
		tween_show.kill()
	tween_show = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_show.tween_property(panel, "modulate:a", 0.0, 0.5)
	await tween_show.finished
	panel.hide()
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	var card: Card = area.owner
	if card.purchased:
		show_screen()

func _on_area_2d_area_exited(area: Area2D) -> void:
	var card: Card = area.owner
	hide_screen()
