class_name WeaponAttributeManager
extends Node

## 通用属性数组
var general_attributes = [
	"MAX_HP", "HP_REGEN", "LIFE_STEAL",
	"PHY_ATK", "MAG_ATK", "CRIT_RATE", "CRIT_DMG", "KNOCKBACK",
	"SEARCH_RAD", "SPAWN_SIZE", "WEAPON_SIZE",
	"PROJ_COUNT", "FLY_SPD", "ROT_SPD", "PEN_RATE",
	"ATK_CD", "EFF_DUR",
]

## 特质属性数组
var trait_attributes = {
	"FIRE": [],
	"FROST": ["DECEL_DUR", "SLOW_RATE", "FREEZE_RATE"],
	"LIGHTING": ["LCH_DMG", "LCH_COUNT"],
	"EARTH": [],
	"TOXIN": ["POISON_LAY", "MAX_POISON", "POISON_DAMAGE"],
	"NATURE": ["NAT_LAY", "NAT_SUM"],
	"DIVINITY": ["DIV_STR"],
	"DEMON": [],
	"SWORD": [],
	"SHIELD": [],
	"AXE": ["PICK_AXE"],
	"SPEAR": [],
	"DAGGER": [],
	"BOW": [],
	"STAFF": [],
	"SCROLL": ["SCROLL_CD_REDUC"],
	"FIREARM": [],
	"STATION": [],
	"BOOK": [],
	"BOOMERANG": []
}

signal update_attributes(scope: WeaponBase.EffectScope, attr: String, source: Variant, type: WeaponBase.AttrType, value: float)

func _ready() -> void:
	pass

func get_base_attributes(weapon_id: int) -> Dictionary:
	var attributes = {}
	
	var weapon_data = WeaponsManager.get_weapon_data_base(weapon_id)
	
	for attr in general_attributes:
		if weapon_data.has(attr):
			attributes[attr] = weapon_data[attr]
		else:
			attributes[attr] = 0.0

	var traits = WeaponsManager.get_traits(weapon_id)

	for _trait in traits:
		for attr in trait_attributes[_trait]:
			if weapon_data.has(attr):
				attributes[attr] = weapon_data[attr]
			else:
				attributes[attr] = 0.0

	return attributes

