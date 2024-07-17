extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coin_count: Label = $CoinCount
@onready var energy: ColorRect = $Energy
@onready var time_left: Label = $TopDec/TimeLeft


var my_player: PlayerBase

var max_energy: float

func _ready() -> void:
	hide()
	
func set_time_left(time: float) -> void:
	time_left.text = str(time)

func show_screen() -> void:
	for player in Levels.players.values():
		if player.multiplayer_id == Tools.my_id():
			my_player = player
			max_energy = player.max_energy
			if not my_player.coin_count_changed.is_connected(_on_coin_count_changed):
				my_player.coin_count_changed.connect(_on_coin_count_changed)
			if not my_player.energy_count_changed.is_connected(_on_energy_count_changed):
				my_player.energy_count_changed.connect(_on_energy_count_changed)
			
			coin_count.text = "0"
			show()
	
func hide_screen() -> void:
	hide()
	
func _on_coin_count_changed(value: int) -> void:
	coin_count.text = str(value)
	if not animation_player.is_playing():
		animation_player.play("CoinJump")

func _on_energy_count_changed(value: float) -> void:
	var percentage := value / max_energy
	energy.material.set_shader_parameter("fill_per", percentage)
	# print("energy: ", percentage)
	
	
