extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coin_count: Label = $CoinCount
@onready var energy: ColorRect = $Energy
@onready var time_left: Label = $TopDec/TimeLeft

var my_player: PlayerBase
var max_energy: float
var fight_timer: Timer

func _ready() -> void:
	my_player = owner
	max_energy = my_player.max_energy
	my_player.coin_count_changed.connect(_on_coin_count_changed)
	my_player.energy_count_changed.connect(_on_energy_count_changed)
	coin_count.text = "0"
	
	if Game.is_game_start():
		show()
	else:
		hide()

func _process(delta) -> void:
	if fight_timer:
		set_time_left(fight_timer.time_left)

func set_time_left(time: float) -> void:
	time_left.text = str(String("%.1f" % time))

func show_screen() -> void:
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
	


