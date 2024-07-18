extends ProjectileBase

const THUNDER_ATTRACTION_LINE = preload("res://src/main/scene/role/effect/Line/thunder_attraction_line.tscn")

@onready var pulling_collision_shape_2d: CollisionShape2D = $PullingArea2D/CollisionShape2D

@export var max_attration_speed: float = 1000.0
@export var attration_speed_curve: Curve

var enemies: Array[EnemyBase] = []
var affected_enemies: Array[EnemyBase] = []
var lines = {}

var pulling: bool = false

func _ready() -> void:
	super()
	
	attributes["KNOCKBACK"] = 200.0
	
	stop_moveing = true
	update_animation.rpc("finish")
	
func _process(delta: float) -> void:
	if not pulling:
		return
	for enemy in lines.keys():
		var line = lines[enemy]
		update_line(line, enemy)

func pulling_enemies() -> void:
	pulling = true
	 
	for enemy in enemies:
		var distance: float = global_position.distance_to(enemy.global_position)
		var dir_to_self: Vector2 = (global_position - enemy.global_position).normalized()
		var velocity_to_self: Vector2 = dir_to_self * max_attration_speed * attration_speed_curve.sample_baked(distance / (pulling_collision_shape_2d.shape.radius * scale.x))
		enemy.velocity = velocity_to_self
		
		affected_enemies.append(enemy)
		
		if not lines.has(enemy):
			var line = THUNDER_ATTRACTION_LINE.instantiate()
			lines[enemy] = line
			Game.add_object(line)
			update_line(line, enemy)
		else:
			var line = lines[enemy]
			update_line(line, enemy)
	
	
func update_line(line, enemy: EnemyBase) -> void:
	line.global_position = global_position
	line.length = global_position.distance_to(enemy.global_position)
	line.look_at(enemy.global_position)

func erase_lines() -> void:
	pulling = false
	
	for enemy in affected_enemies:
		enemy.velocity = Vector2.ZERO
	
	for enemy in lines.keys():
		var line = lines[enemy]
		if is_instance_valid(line): line.queue_free()
	lines.clear()

func _on_hit_box_hit(hurtbox: Variant) -> void:
	super(hurtbox)

	deferred_add_lighting_chain.call_deferred()

func _on_pulling_area_2d_body_entered(enemy: EnemyBase) -> void:
	if enemy.is_in_group("enemy") and not enemies.has(enemy):
		enemies.append(enemy)
		if not enemy.enemy_die.is_connected(_on_enemy_die):
			enemy.enemy_die.connect(_on_enemy_die)

func _on_pulling_area_2d_body_exited(enemy: EnemyBase) -> void:
	if enemy.is_in_group("enemy") and enemies.has(enemy):
		enemies.erase(enemy)
		
		if lines.has(enemy):
			var line = lines[enemy]
			if is_instance_valid(line): line.queue_free()
			lines.erase(enemy)
			
		if enemy.enemy_die.is_connected(_on_enemy_die):
			enemy.enemy_die.disconnect(_on_enemy_die)
			
func _on_enemy_die(dead_enemy: EnemyBase) -> void:
	if enemies.has(dead_enemy):
		enemies.erase(dead_enemy)
