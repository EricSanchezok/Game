extends PlayerBase

@onready var coin_generator: CoinGenerator = $CoinGenerator



func _ready() -> void:
	super()

func _unhandled_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("test"):
		coin_generator.generate_coins(1, 1)
