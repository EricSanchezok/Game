extends TextureProgressBar

@onready var health_bar: TextureProgressBar = $"."
@onready var eased_health_bar: TextureProgressBar = $EasedHealthBar
@onready var shield_bar: TextureProgressBar = $ShieldBar

var tween_shield: Tween

func _ready() -> void:
	hide()
	
	if not owner.is_node_ready(): await owner.ready
	
	health_bar.value = 1.0
	eased_health_bar.value = 1.0
	shield_bar.value = 0.0
	
	owner.recalculate_attribute.connect(_on_recalculate_attribute)
	

func _on_recalculate_attribute(attr: String, value: float) -> void:
	
	match attr:
		"HP":
			update_health(false)
		
		"SHIELD":
			update_shield()
	
func update_health(shield_change: bool = false) -> void:
	var shield_rate = shield_bar.value
	var health_rate = 1 - shield_rate
	
	var percentage = health_rate * owner.attributes["HP"] / owner.attributes["MAX_HP"]
	health_bar.value = percentage
	
	if not shield_change:
		var tween = create_tween().tween_property(eased_health_bar, "value", percentage, 0.3)
	else:
		eased_health_bar.value = percentage
		
func update_shield() -> void:
	var shield_rate = owner.attributes["SHIELD"] / (owner.attributes["MAX_HP"] + owner.attributes["SHIELD"])
	
	
	if tween_shield and tween_shield.is_running():
		tween_shield.kill()
	tween_shield = create_tween()
	tween_shield.tween_property(shield_bar, "value", shield_rate, 0.2)
	
	update_health(true)
	
