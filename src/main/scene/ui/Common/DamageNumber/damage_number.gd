extends Marker2D

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var phy_color: Color
@export var mag_color: Color
@export var critical_color: Color

# 传递参数
var damage: Damage
var type: String = "phy"

# 内部参数
var velocity: Vector2
var deceleration: float = 400.0

func _ready() -> void:
	animation_player.play("default")
	
	var target_scale = Vector2.ONE
	var damage_amount = 0.0
	
	if type == "phy":
		label.modulate = phy_color
		damage_amount = damage.phy_amount
		
	if type == "mag":
		label.modulate = mag_color
		damage_amount = damage.mag_amount
		
	if damage.is_critical:
		label.modulate = critical_color
		target_scale = Vector2(1.5, 1.5)
		
	var tween_scale = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_scale.tween_property(self, "scale", target_scale, 0.3).from(Vector2.ZERO)
	
	update_text(damage_amount)
	
	velocity = Vector2(randf_range(-50, 50), randf_range(-200, -120))

func _process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)
	global_position += velocity * delta

func update_text(number: float) -> void:
	if number == int(number):
		label.text = str(int(number))
	else:
		label.text = str(String("%.1f" % number))
