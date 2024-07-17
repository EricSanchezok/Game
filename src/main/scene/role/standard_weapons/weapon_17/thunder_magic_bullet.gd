extends ProjectileBase

const THUNDER_ATTRACTION_LINE = preload("res://src/main/scene/role/effect/Line/thunder_attraction_line.tscn")


@onready var animated_sprite_2d: AnimatedSprite2D = $Graphics/AnimatedSprite2D
@onready var traction_collision_shape_2d: CollisionShape2D = $TractionArea2D/CollisionShape2D

@export var max_attration_speed: float = 100.0
@export var max_attraction_acceleration: float = 3000.0
@export var attraction_acceleration_curve: Curve

var enemies: Array[EnemyBase] = []
var lines = {}

func _ready() -> void:
	super()
	
	tracking = true
	bezier = true
	in_front = true
	in_front_dis = 10
	
	animated_sprite_2d.play("idle")
	
func do_tick_moving(delta: float) -> void:
	for enemy in enemies:
		if not enemy.attraction_sources[0] == self:
			return
		var distance: float = global_position.distance_to(enemy.global_position)
		var dir_to_self: Vector2 = (global_position - enemy.global_position).normalized()
		var velocity_to_self: Vector2 = dir_to_self * max_attration_speed
		var attraction_acceleration = max_attraction_acceleration * attraction_acceleration_curve.sample_baked(distance / (traction_collision_shape_2d.shape.radius * scale.x))
		enemy.velocity = enemy.velocity.move_toward(velocity_to_self, attraction_acceleration * delta)
		
		if not lines.has(enemy):
			var line = THUNDER_ATTRACTION_LINE.instantiate()
			lines[enemy] = line
			Levels.activated_level.add_child(line, true)
			update_line(line, enemy)
		else:
			var line = lines[enemy]
			update_line(line, enemy)
			
func update_line(line, enemy: EnemyBase) -> void:
	line.global_position = global_position
	line.length = global_position.distance_to(enemy.global_position)
	line.look_at(enemy.global_position)
	
func scale_down() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(animated_sprite_2d, "scale", Vector2.ZERO, 0.2)
	
func _on_reach_target() -> void:
	super()
	
	for line in lines.values():
		line.hide()
		if is_instance_valid(line): line.queue_free()
	lines.clear()
	
	update_animation.rpc("finish")
	
func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)
	
	deferred_add_lighting_chain.call_deferred()

func _on_traction_area_2d_body_entered(enemy: EnemyBase) -> void:
	if enemy.is_in_group("enemy") and not enemies.has(enemy):
		enemies.append(enemy)
		enemy.attraction_sources.append(self)
		if not enemy.enemy_die.is_connected(_on_enemy_die):
			enemy.enemy_die.connect(_on_enemy_die)

func _on_traction_area_2d_body_exited(enemy: EnemyBase) -> void:
	if enemy.is_in_group("enemy") and enemies.has(enemy):
		enemies.erase(enemy)
		enemy.attraction_sources.erase(self)
		
		if lines.has(enemy):
			var line = lines[enemy]
			if is_instance_valid(line): line.queue_free()
			lines.erase(enemy)
			
		if enemy.enemy_die.is_connected(_on_enemy_die):
			enemy.enemy_die.disconnect(_on_enemy_die)
			
func _on_enemy_die(dead_enemy: EnemyBase) -> void:
	if enemies.has(dead_enemy):
		enemies.erase(dead_enemy)
