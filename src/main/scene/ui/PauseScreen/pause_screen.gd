extends Control


@onready var settings_button: Button = $PanelContainer/VBoxContainer/SettingsButton
@onready var back_to_camp_button: Button = $PanelContainer/VBoxContainer/BackToCampButton
@onready var quit_game_button: Button = $PanelContainer/VBoxContainer/QuitGameButton

func _ready() -> void:
	hide()
	if Game.is_game_start():
		back_to_camp_button.show()
		quit_game_button.hide()
	else:
		back_to_camp_button.hide()
		quit_game_button.show()
		
	settings_button.pressed.connect(_on_settings_button_pressed)
	back_to_camp_button.pressed.connect(_on_back_to_camp_button_pressed)
	quit_game_button.pressed.connect(_on_quit_game_button_pressed)
	
func show_screen() -> void:
	show()
	
func hide_screen() -> void:
	hide()
	
func switch() -> void:
	if visible: hide_screen()
	else: show_screen()

func _on_settings_button_pressed() -> void:
	pass

func _on_back_to_camp_button_pressed() -> void:
	Game.change_scene("res://src/main/scene/level/Campsite/campsite.tscn")
	
func _on_quit_game_button_pressed() -> void:
	pass

