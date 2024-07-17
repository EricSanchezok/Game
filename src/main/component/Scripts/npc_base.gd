class_name Npc
extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	var template_material = sprite_2d.material.duplicate()
	sprite_2d.material = template_material
	
	interactable.sprite_2d = sprite_2d
	interactable.highlight.connect(_on_highlight)
	interactable.unhighlight.connect(_on_unhighlight)
	
	
func _on_highlight() -> void:
	if is_instance_valid(sprite_2d):
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(sprite_2d.material, "shader_parameter/color", Color.WHITE, 0.3).from(Color.TRANSPARENT)

func _on_unhighlight() -> void:
	if is_instance_valid(sprite_2d):
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(sprite_2d.material, "shader_parameter/color", Color.TRANSPARENT, 0.3).from(Color.WHITE)

