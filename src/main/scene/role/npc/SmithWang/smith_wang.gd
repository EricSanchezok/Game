extends Npc

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	animation_player.play("idle")

func _on_interactable_interacted(player: PlayerBase) -> void:
	pass
