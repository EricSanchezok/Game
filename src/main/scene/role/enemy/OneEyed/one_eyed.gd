extends ShooterMonster
				
func _ready() -> void:
	super()
	# 属性更改
	match enemy_type:
		"A":
			base_attributes = {
				"MAX_HP": 100.0,
				"HP": 100.0,
				"HP_REGEN": 0.5,
				"MOV_SPD": 50.0,
				"ACCEL": 2000.0,
				"DMG": 1.0,
				"KNB_RES": 0.1,
				"SLOW_RES": 0.1,
				"FRZ_RES": 0.0,
				
				# ShooterMonster 专有属性
				"SHOOT_PATH": "res://src/main/scene/role/enemy/Bullets/normal_bullet.tscn",
				"SHOOT_DIST": 150.0,
				"SHOOT_DMG": 1.0,
				"SHOOT_WAIT": 1.0,
				"SHOOT_SPD": 60.0,
				"SHOOT_LIFE": 10.0
			}
			
		"B":
			base_attributes = {
				"MAX_HP": 100.0,
				"HP": 100.0,
				"HP_REGEN": 0.5,
				"MOV_SPD": 50.0,
				"ACCEL": 2000.0,
				"DMG": 1.0,
				"KNB_RES": 0.1,
				"SLOW_RES": 0.1,
				"FRZ_RES": 0.0,
				
				# ShooterMonster 专有属性
				"SHOOT_PATH": "res://src/main/scene/role/enemy/Bullets/normal_bullet.tscn",
				"SHOOT_DIST": 150.0,
				"SHOOT_DMG": 1.0,
				"SHOOT_WAIT": 1.0,
				"SHOOT_SPD": 60.0,
				"SHOOT_LIFE": 10.0
			}
			
		"C":
			base_attributes = {
				"MAX_HP": 100.0,
				"HP": 100.0,
				"HP_REGEN": 0.5,
				"MOV_SPD": 50.0,
				"ACCEL": 2000.0,
				"DMG": 1.0,
				"KNB_RES": 0.1,
				"SLOW_RES": 0.1,
				"FRZ_RES": 0.0,
				
				# ShooterMonster 专有属性
				"SHOOT_PATH": "res://src/main/scene/role/enemy/Bullets/normal_bullet.tscn",
				"SHOOT_DIST": 150.0,
				"SHOOT_DMG": 1.0,
				"SHOOT_WAIT": 1.0,
				"SHOOT_SPD": 60.0,
				"SHOOT_LIFE": 10.0
			}
			
		"D":
			base_attributes = {
				"MAX_HP": 100.0,
				"HP": 100.0,
				"HP_REGEN": 0.5,
				"MOV_SPD": 50.0,
				"ACCEL": 2000.0,
				"DMG": 1.0,
				"KNB_RES": 0.1,
				"SLOW_RES": 0.1,
				"FRZ_RES": 0.0,
				
				# ShooterMonster 专有属性
				"SHOOT_PATH": "res://src/main/scene/role/enemy/Bullets/normal_bullet.tscn",
				"SHOOT_DIST": 150.0,
				"SHOOT_DMG": 1.0,
				"SHOOT_WAIT": 1.0,
				"SHOOT_SPD": 60.0,
				"SHOOT_LIFE": 10.0
			}
