extends CollisionMonster



const ENEMY_011_A = preload("res://src/main/assets/packs/16X16/Rogue Adventure World 2.6.0/Monsters/Sprites Scaled 2x/Enemy_011_A.png")
const ENEMY_011_B = preload("res://src/main/assets/packs/16X16/Rogue Adventure World 2.6.0/Monsters/Sprites Scaled 2x/Enemy_011_B.png")
const ENEMY_011_C = preload("res://src/main/assets/packs/16X16/Rogue Adventure World 2.6.0/Monsters/Sprites Scaled 2x/Enemy_011_C.png")
const ENEMY_011_D = preload("res://src/main/assets/packs/16X16/Rogue Adventure World 2.6.0/Monsters/Sprites Scaled 2x/Enemy_011_D.png")


enum EnemyType {
	A,
	B,
	C,
	D
}

@export var enemy_type = EnemyType.A:
	set(v):
		enemy_type = v
		if not is_node_ready(): await ready
		match enemy_type:
			EnemyType.A:
				sprite_2d.texture = ENEMY_011_A
			EnemyType.B:
				sprite_2d.texture = ENEMY_011_B
			EnemyType.C:
				sprite_2d.texture = ENEMY_011_C
			EnemyType.D:
				sprite_2d.texture = ENEMY_011_D
