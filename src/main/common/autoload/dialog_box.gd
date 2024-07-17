extends CanvasLayer

@onready var content: Label = $MarginContainer/Content
@onready var avatar: TextureRect = $MarginContainer/Content/Avatar
@onready var next_indicator: TextureRect = $MarginContainer/Content/NextIndicator

@onready var options_container: HBoxContainer = $MarginContainer/Content/OptionsContainer
@onready var button_1: Button = $MarginContainer/Content/OptionsContainer/MyButton1
@onready var button_2: Button = $MarginContainer/Content/OptionsContainer/MyButton2

@onready var text_edit: TextEdit = $MarginContainer/Content/TextEdit
@onready var confirm_button: Button = $MarginContainer/Content/ConfirmMyButton


const AVATAP_MAP = {
	"MIRA_LINK" = preload("res://src/main/scene/role/npc/Avatars/MiraLink.tres"),
	
}

var dialogs = []
var current: int = 0
var tween: Tween
var interval: float = 0.02
var player: PlayerBase
var first: bool = true
var is_callable_finished: bool = false:
	set(v):
		is_callable_finished = v
		if is_callable_finished:
			next_indicator.show()
			
signal interact_pressed
			
			
func _ready() -> void:
	hide()
	options_container.hide()
	confirm_button.hide()
	text_edit.hide()
	$AnimationPlayer.play("idle")

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("esc"):
		hide_screen()
		
	if not is_callable_finished:
		return
	if event.is_action_pressed("interact"):
		interact_pressed.emit()
		if first:
			first = false
			return
		if tween and tween.is_running():
			tween.kill()
			content.visible_ratio = 1.0
			next_indicator.show()
		elif current + 1 < dialogs.size():
			_show_dialog(current + 1)
		else:
			hide_screen()
		get_viewport().set_input_as_handled()



	
func show_screen() -> void:
	show()
	
func hide_screen() -> void:
	hide()
	options_container.hide()
	confirm_button.hide()
	text_edit.hide()
	
	player.lock_input = false
	first = true
	dialogs = []
	current = 0
	
func show_dialog_box(_dialogs) -> void:
	dialogs = _dialogs
	show_screen()
	_show_dialog(0)
	
	
func _show_dialog(index) -> void:
	current = index
	var dialog = dialogs[current]
	content.text = dialog.text
	
	next_indicator.hide()
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(content, "visible_ratio", 1.0, interval * content.text.length()).from(0.0)
	
	if dialog.callable:
		is_callable_finished = false
		dialog.callable.call()
	else:
		is_callable_finished = true
		await tween.finished
		next_indicator.show()
		
		
func show_options(text1: String, text2: String) -> void:
	button_1.text = text1
	button_2.text = text2
	options_container.show()
	
func hide_options() -> void:
	options_container.hide()
	
func show_text_edit() -> void:
	text_edit.show()
	#confirm_button.show()

func hide_text_edit() -> void:
	text_edit.hide()
	confirm_button.hide()
	
	
	


func _on_confirm_button_pressed() -> void:
	hide_text_edit()


func _on_my_button_1_pressed() -> void:
	hide_options()


func _on_my_button_2_pressed() -> void:
	hide_options()


func _on_confirm_my_button_pressed() -> void:
	hide_text_edit()


func _on_text_edit_text_changed() -> void:
	if text_edit.text == "":
		confirm_button.hide()
	else:
		confirm_button.show()
