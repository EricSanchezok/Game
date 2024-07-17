class_name HitBox
extends Area2D

signal hit(hurtbox)

@export var slave_mode: bool = false

func _init() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(hurtbox: HurtBox) -> void:
	# print("[Hit] %s => %s" % [owner.name, hurtbox.owner.name])
	hurtbox.hurt.emit(self)
	hit.emit(hurtbox)

