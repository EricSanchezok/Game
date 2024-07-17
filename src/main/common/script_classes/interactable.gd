class_name Interactable
extends Area2D

var sprite_2d: Sprite2D

signal interacted(player: PlayerBase)
signal highlight
signal unhighlight

var players = []

func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(2, true)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func interact(player: PlayerBase) -> void:
	print("[Interact] %s" % owner.name)
	interacted.emit(player)

func _on_body_entered(player: PlayerBase) -> void:
	player.register_interactable(self)
	players.append(player)
	if players.size() == 1:
		highlight.emit()
	
func _on_body_exited(player: PlayerBase) -> void:
	player.unregister_interactable(self)
	players.erase(player)
	if players.size() == 0:
		unhighlight.emit()

