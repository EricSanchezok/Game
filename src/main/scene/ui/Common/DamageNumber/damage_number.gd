extends Marker2D

var text:
	set(v):
		$Label.text = str(String("%.1f" % v))
		text = v

var velocity: Vector2
var gravity: Vector2
var mass: float

var type: String = "phy"

var is_critical: bool = false

func _ready() -> void:
	$AnimationPlayer.play("default")
	var target_scale = Vector2.ONE
	if type == "phy":
		$Label.modulate = Color.GREEN
	if type == "mag":
		$Label.modulate = Color.DODGER_BLUE
	if is_critical:
		$Label.modulate = Color.RED
		target_scale = Vector2(1.5, 1.5)
	var tween_scale = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_scale.tween_property(self, "scale", target_scale, 0.3).from(Vector2.ZERO)
	

	
func _process(delta: float) -> void:
	velocity += gravity * mass * delta
	global_position += velocity * delta


