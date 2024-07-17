class_name SpawnShape2D
extends CollisionShape2D


@export var probability: float = 1.0


func _ready() -> void:
	add_to_group("SpawnShape")
