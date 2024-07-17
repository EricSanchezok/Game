extends Area2D

@onready var shadow: Sprite2D = $Shadow
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var energy_sprite_2d: Sprite2D = $EnergySprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var player: PlayerBase

var type: String = "Coin"
var value: int

var can_be_absorbed: bool = false
var ready_to_be_absorbed: bool = false

var start_point: Vector2
var target_point: Vector2
var control_point: Vector2
var control_height: float
var total_time: float

var current_time: float = 0.0

var absorbed_speed: float = -200.0
var absorbed_acceleration: float = 1000.0


func _ready() -> void:
	if type == "Coin":
		$AnimationPlayer.play("default")
		sprite_2d.show()
		energy_sprite_2d.hide()
		point_light_2d.hide()
	if type == "Energy":
		sprite_2d.hide()
		energy_sprite_2d.show()
		point_light_2d.show()
		scale *= 0.8

	if not is_multiplayer_authority():
		return
	
	start_point = global_position
	control_point = (start_point + target_point) / 2
	control_point.y -= control_height
	
	
func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		
	if not can_be_absorbed:
		current_time += delta
		var t = min(current_time/total_time, 1)
		var next_point = start_point.bezier_interpolate(control_point, target_point, target_point, t)
		global_position = next_point
		
		shadow.global_position.x = next_point.x
		shadow.global_position.y = target_point.y + 6
		
		if global_position == target_point:
			can_be_absorbed = true
	else:
		if ready_to_be_absorbed:
			absorbed_speed += absorbed_acceleration * delta
			global_position = global_position.move_toward(player.global_position, absorbed_speed*delta)
			
			if global_position.distance_squared_to(player.global_position) <= 25:
				if type == "Coin":
					player.change_coin.rpc(value)
					
				if type == "Energy":
					player.change_energy.rpc(value)
					
				queue_free() # free 经过测试好像不需要 rpc 来调用，只要主机 free 掉就可以
				
	
func _on_area_entered(area: Area2D) -> void:
	if not is_multiplayer_authority():
		return
	player = area.owner
	ready_to_be_absorbed = true

func _on_area_exited(area: Area2D) -> void:
	if not is_multiplayer_authority():
		return
	if not can_be_absorbed:
		ready_to_be_absorbed = false
