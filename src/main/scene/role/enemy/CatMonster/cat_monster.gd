extends DashMonster


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
				
				# DashMonster 专有属性
				"DASH_PRE_DIST": 80.0,
				"DASH_DIST": 160.0,
				"DASH_TIME": 0.5,
				"DASH_INIT_SPD": 500.0,
				"DASH_PAUSE": 0.5,
				"DASH_WAIT": 2.0,
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
				
				# DashMonster 专有属性
				"DASH_PRE_DIST": 80.0,
				"DASH_DIST": 160.0,
				"DASH_TIME": 0.5,
				"DASH_INIT_SPD": 500.0,
				"DASH_PAUSE": 0.5,
				"DASH_WAIT": 2.0,
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
				
				# DashMonster 专有属性
				"DASH_PRE_DIST": 80.0,
				"DASH_DIST": 160.0,
				"DASH_TIME": 0.5,
				"DASH_INIT_SPD": 500.0,
				"DASH_PAUSE": 0.5,
				"DASH_WAIT": 2.0,
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
				
				# DashMonster 专有属性
				"DASH_PRE_DIST": 80.0,
				"DASH_DIST": 160.0,
				"DASH_TIME": 0.5,
				"DASH_INIT_SPD": 500.0,
				"DASH_PAUSE": 0.5,
				"DASH_WAIT": 2.0,
			}

