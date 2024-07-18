extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var weapon: WeaponBase
var attributes: Dictionary
var shield_increment: float
var knockback_increment: float
var pen_rate_increment: float
var enemy_bullet_speed_multiplier: float

var in_area_players: Array[PlayerBase]
var in_area_bullets: Array[EnemyProjectileBase]

func _ready() -> void:
	attributes = weapon.attributes.duplicate(true)
	
	timer.wait_time = attributes["EFF_DUR"]
	timer.start()
	
	animation_player.play("init")
	
func _on_ready() -> void:
	Tools.apply_spawn_object_size_multiplier(self)
	
	
func _process(delta: float) -> void:
	for player in in_area_players:
		player.update_attributes.emit("SHIELD", self, PlayerBase.AttrType.FIXED, shield_increment * delta)
		#player.player_stats.current_shield += shield_increment * delta


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBase:
		body.wam.update_attributes.emit(WeaponBase.EffectScope.GLOBAL, "KNOCKBACK", self, WeaponBase.AttrType.MULT, knockback_increment)
		body.wam.update_attributes.emit(WeaponBase.EffectScope.GLOBAL, "PEN_RATE", self, WeaponBase.AttrType.MULT, pen_rate_increment)

		in_area_players.append(body)
	
	elif body is EnemyProjectileBase:
		body.speed *= enemy_bullet_speed_multiplier
		
		in_area_bullets.append(body)
		
func _on_body_exited(body: Node2D) -> void:
	if body is PlayerBase:
		body.wam.update_attributes.emit(WeaponBase.EffectScope.GLOBAL, "KNOCKBACK", self, WeaponBase.AttrType.MULT, -knockback_increment)
		body.wam.update_attributes.emit(WeaponBase.EffectScope.GLOBAL, "PEN_RATE", self, WeaponBase.AttrType.MULT, -pen_rate_increment)

		in_area_players.erase(body)
		
	elif body is EnemyProjectileBase:
		body.speed /= enemy_bullet_speed_multiplier
		
		in_area_bullets.erase(body)


func _on_timer_timeout() -> void:
	for player in in_area_players:
		player.wam.update_attributes.emit(WeaponBase.EffectScope.GLOBAL, "KNOCKBACK", self, WeaponBase.AttrType.MULT, -knockback_increment)
		player.wam.update_attributes.emit(WeaponBase.EffectScope.GLOBAL, "PEN_RATE", self, WeaponBase.AttrType.MULT, -pen_rate_increment)
		
	for bullet in in_area_bullets:
		bullet.speed /= enemy_bullet_speed_multiplier
	
	queue_free()



