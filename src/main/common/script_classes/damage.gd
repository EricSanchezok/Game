class_name Damage
extends RefCounted

var source_weapon: WeaponBase
var direct_object
## 该参数通常为 攻击者 朝向 被攻击者 的方向
var direction: Vector2 = Vector2.ZERO

var is_critical: bool = false

var phy_amount: float = 0.0
var mag_amount: float = 0.0
var knockback: float = 0.0

## 用于自适应的一些其他参数
var other

## 为敌人攻击玩家特有的 amount
var amount: float = 0.0



