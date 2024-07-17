extends Control

const SUPER_BOMB = preload("res://src/main/scene/role/standard_weapons/weapon_6/super_bomb.tscn")

@onready var color_rect: ColorRect = $ColorRect
@onready var scope_texture_rect: TextureRect = $ScopeTextureRect
@onready var reload_timer: Timer = $ReloadTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var can_shoot: bool = false

var weapon_instance: FirearmBase
var shoot_position: Vector2

func _ready() -> void:
	set_process(false)
	hide()
	
func show_screen() -> void:
	show()
	set_process(true)
	for max_level_weapon in owner.max_level_weapons:
		if max_level_weapon["weapon_id"] == 6:
			weapon_instance = max_level_weapon["weapon_instance"]
			break
	animation_player.play("show_screen")
	
func hide_screen() -> void:
	hide()
	set_process(false)
	can_shoot = false

func _process(delta: float) -> void:
	
	var mouse_pos = get_viewport().get_mouse_position()
	
	scope_texture_rect.position = mouse_pos - scope_texture_rect.size / 2
	
	var center_pos = Vector2(mouse_pos.x / get_viewport_rect().size.x, mouse_pos.y / get_viewport_rect().size.y)
	color_rect.material.set_shader_parameter("circle_center", center_pos)
	
func shoot_bullet() -> void:
	if not is_multiplayer_authority():
		return
		
	add_bullet.rpc()

@rpc("authority", "call_local")
func add_bullet() -> void:
	var instance: ProjectileBase = SUPER_BOMB.instantiate()
	
	instance.target_pos = shoot_position
	instance.weapon = weapon_instance

	Game.add_object(instance)
	
func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	

	if event.is_pressed(): # 按下鼠标时
		if can_shoot:
			animation_player.play("shoot")
			reload_timer.start()
			can_shoot = false
			
			var camera_2d = get_viewport().get_camera_2d()
			var mouse_pos = camera_2d.global_position + get_global_mouse_position() - get_viewport_rect().size / 2
			shoot_position = mouse_pos
			
		else:
			pass
		
	else: # 松开鼠标时
		pass


func _on_reload_timer_timeout() -> void:
	animation_player.play("reload")
