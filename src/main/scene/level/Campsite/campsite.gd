extends Node2D

func _ready() -> void:
	pass

func _on_my_button_pressed() -> void:
	Game.change_scene("res://src/main/scene/level/RightThereOnTheMeadow/right_there_on_the_meadow.tscn")
