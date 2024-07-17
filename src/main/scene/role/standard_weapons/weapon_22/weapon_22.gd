extends BoomerangBase

var shield_increment: float = 0.1 ## （调整参数）每击中一个敌人增加的护盾量

func _ready() -> void:
	super()

func level_up(level: int) -> void:
	super(level)

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	player.update_attributes.emit("SHIELD", self, PlayerBase.AttrType.FIXED, shield_increment)
	#player.attributes["SHIELD"] += shield_increment
	
	
