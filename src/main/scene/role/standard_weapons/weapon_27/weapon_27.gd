extends SpearBase

@onready var shield_collision_shape_2d: CollisionShape2D = $Graphics/ShieldHitBox/CollisionShape2D
@onready var shield: Sprite2D = $Graphics/Shield
@onready var shield_hitbox_timer: Timer = $ShieldHitboxTimer
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

var recovery_time: float = 5.0 ## （调整参数）盾牌被破坏后恢复所需要的时间
var life_steal_increment: float = 0.2 ## （调整参数）盾牌被破坏后的生命偷取的增幅值
var damage_multiplier: float = 0.5 ## （调整参数）盾牌被破坏后的伤害增幅倍率
var attack_cooldown_multiplier: float = 0.8 ## （调整参数）盾牌被破坏后的攻速增幅倍率
var slave_damage_multiplier: float = 0.05 ## （调整参数）盾牌造成的伤害占自身伤害的百分比（注意盾牌与敌人碰撞后每0.2s造成一次伤害）
var slave_knockback_multiplier: float = 0.0 ## （调整参数）盾牌造成的击退占自身击退的百分比



@export var current_health: float:
	set(v):
		if not is_node_ready():	await ready
		if current_health == v:
			return
		current_health = clampf(v, -1, attributes["MAX_HP"])
		texture_progress_bar.value = current_health / attributes["MAX_HP"]

var need_recovery: bool = false
var recovery_time_left: float

func _ready() -> void:
	super()
	
	shield_hitbox_timer.start()

func _on_ready() -> void:
	super()
	
	current_health = attributes["MAX_HP"]

func level_up(level: int) -> void:
	super(level)
	
func do_tick(delta: float) -> void:
	if need_recovery:
		recovery_time_left -= delta
		
	if recovery_time_left < 0.0:
		shield_recovery()
		
	restore_health(delta)
	
func shield_destruction() -> void:
	animation_player.play("recovering")
	shield_hitbox_timer.stop()
	shield_collision_shape_2d.disabled = true
	
	wam.update_attributes.emit(EffectScope.SELF, "LIFE_STEAL", self, AttrType.FIXED, life_steal_increment)
	wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, damage_multiplier)
	wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, damage_multiplier)
	wam.update_attributes.emit(EffectScope.SELF, "ATK_CD", self, AttrType.MULT, attack_cooldown_multiplier)
	
	recovery_time_left = recovery_time
	need_recovery = true

func shield_recovery() -> void:
	animation_player.play("appear")
	shield_hitbox_timer.start()
	shield_collision_shape_2d.disabled = false
	
	wam.update_attributes.emit(EffectScope.SELF, "LIFE_STEAL", self, AttrType.FIXED, -life_steal_increment)
	wam.update_attributes.emit(EffectScope.SELF, "PHY_ATK", self, AttrType.MULT, -damage_multiplier)
	wam.update_attributes.emit(EffectScope.SELF, "MAG_ATK", self, AttrType.MULT, -damage_multiplier)
	wam.update_attributes.emit(EffectScope.SELF, "ATK_CD", self, AttrType.MULT, -attack_cooldown_multiplier)

	current_health = attributes["MAX_HP"]
	recovery_time_left = 0.0
	need_recovery = false

func restore_health(delta) -> void:
	if current_health > 0.0:
		current_health += attributes["HP_REGEN"] * delta
		
func _on_shield_hitbox_timer_timeout() -> void:
	shield_collision_shape_2d.disabled = true if not shield_collision_shape_2d.disabled else false

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	pass

func _on_shield_hit_box_hit(hurtbox: Variant) -> void:
	if current_health < 0:
		return
		
	if not animation_player.is_playing():
		animation_player.play("hurt")
		
	var damage: Damage = Damage.new()
	damage.direct_object = hurtbox.owner
	damage.amount = damage.direct_object.attributes["DMG"]

	current_health -= damage.amount
	if current_health < 0:
		shield_destruction.call_deferred()
