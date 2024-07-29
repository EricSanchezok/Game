class_name ShieldBase
extends WeaponBase

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var hitbox_collision_shape_2d: CollisionShape2D = $Graphics/HitBox/CollisionShape2D
@onready var shield_hitbox_timer: Timer = $ShieldHitboxTimer

@export var current_health: float:
	set(v):
		if not is_node_ready():	await ready
		if current_health == v:
			return
		current_health = clampf(v, -1, attributes["MAX_HP"])
		texture_progress_bar.value = current_health / attributes["MAX_HP"]

func _ready() -> void:
	super()
	
func _on_ready() -> void:
	shield_hitbox_timer.timeout.connect(_on_shield_hitbox_timer_timeout)
	
	shield_hitbox_timer.start()
	
func level_up(level) -> void:  #升级增加减速幅度和冻结率
	super(level)
	
enum State {
	APPEAR,
	WAIT,
	RECOVERING
}

func tick_physics(state: State, delta: float) -> void:
	base_tick(delta)
	
	do_tick(delta)
	
	sync_slot_position.rpc()
		
	match state:
		State.APPEAR:
			do_tick_appear(delta)
			
		State.WAIT:
			do_tick_wait(delta)
			
			restore_health(delta)

		State.RECOVERING:
			do_tick_recovering(delta)
			
func get_next_state(state: State) -> int:

	match state:
		State.APPEAR:
			if not animation_player.is_playing():
				return State.WAIT
				
		State.WAIT:
			if current_health < 0: # 这里不能等于0，因为初始时 current_health 因为节点加载顺序一直是 0，所以这为了避免初始就进入恢复
				return State.RECOVERING
				
		State.RECOVERING:
			if cooling_complete():
				return State.APPEAR
				
				
	return StateMachine.KEEP_CURRENT
	
func transition_state(from: State, to: State) -> void:	
	print("[%s] %s => %s" % [Engine.get_physics_frames(),State.keys()[from] if from != -1 else "<START>",State.keys()[to],]) 
	match from:
		State.APPEAR:
			pass
				
		State.WAIT:
			pass
			#hitbox_collision_shape_2d.disabled = true
				
		State.RECOVERING:
			pass
				
			
	match to:
		State.APPEAR:
			do_enter_appear()
			
			current_health = attributes["MAX_HP"]
			
			animation_player.play("appear")
			var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(texture_progress_bar, "self_modulate:a", 1.0, 0.3).from(0.0)
			
		State.WAIT:
			do_enter_wait()
			
			hitbox_collision_shape_2d.disabled = false
			shield_hitbox_timer.start()
			
		State.RECOVERING:
			do_enter_recovering()
			
			animation_player.play("recovering")
			var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(texture_progress_bar, "self_modulate:a", 0.0, 0.3).from(1.0)
			recovery_cooldown()
			
			hitbox_collision_shape_2d.disabled = true
			shield_hitbox_timer.stop()
			
func restore_health(delta) -> void:
	if current_health > 0.0:
		current_health += attributes["HP_REGEN"] * delta
		
func do_tick(delta: float) -> void:
	pass

func do_tick_appear(delta: float) -> void:
	pass
	
func do_tick_wait(delta: float) -> void:
	pass
	
func do_tick_recovering(delta: float) -> void:
	pass
	
func do_enter_appear() -> void:
	pass
	
func do_enter_wait() -> void:
	pass
	
func do_enter_recovering() -> void:
	pass
	
func _on_shield_hitbox_timer_timeout() -> void:
	hitbox_collision_shape_2d.disabled = true if not hitbox_collision_shape_2d.disabled else false
	
func _on_hit_box_hit(hurtbox: Variant) -> void:
	if not animation_player.is_playing():
		animation_player.play("hurt")
		
	var damage: Damage = Damage.new()
	damage.direct_object = hurtbox.owner
	damage.amount = damage.direct_object.attributes["DMG"]
	
	current_health -= damage.amount
