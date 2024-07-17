class_name AtmosphereSystem
extends Node

# 8-16纯白天
# 16-20傍晚
# 20-4纯黑
# 4-8黎明
@onready var combined: Control = $CanvasLayer/Combined

@onready var timer: Timer = $Timer
@onready var rand_weather_timer: Timer = $RandWeatherTimer
@onready var strobe_timer: Timer = $StrobeTimer


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 昼夜系统 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@export var auto_deduction: bool = false
@export var real_time: bool = false
@export var cycle_time: float = 10
@export var gradient: GradientTexture1D
var target_canvas_modulate: CanvasModulate

enum TimeType{
	DAYTIME,
	EVENING,
	LATE_NIGHT,
	EARLY_MORNING,
}

var current_time_type: TimeType = TimeType.DAYTIME:
	set(v):
		if current_time_type != v:
			update_lights(v)
		current_time_type = v
		
var current_time: float = 8:
	set(v):
		current_time = fmod(v, 24)
		var mapping_time = 16 + current_time if current_time < 8 else current_time - 8
		target_canvas_modulate.color = gradient.gradient.sample(mapping_time/24.0)
		update_time_type()


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 天气系统 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
@export var wind_speed: float = 0.0:
	set(v):
		wind_speed = clampf(v, -1, 1)
		
@onready var rain_and_snow: ColorRect = $CanvasLayer/Combined/RainAndSnow
@onready var fog: ColorRect = $CanvasLayer/Combined/ParallaxBackground/ParallaxLayer/Fog
@onready var sunny: ColorRect = $CanvasLayer/Combined/Sunny
@onready var strobe: ColorRect = $CanvasLayer/Combined/Strobe
	

@export var rand_weather: bool = false:
	set(v):
		rand_weather = v
		if not rand_weather:
			return
		await ready
		rand_weather_timer.start()
@export var wait_time: float = 1.0:
	set(v):
		wait_time = v
		await ready
		rand_weather_timer.wait_time = wait_time

enum Weather {
	NONE,	 # 无
	SUNNY,    # 晴朗
	RAINY,    # 雨天
	STORMY,   # 暴风雨
	SNOWY,    # 下雪
	FOGGY,    # 雾天
}
signal weather_change(from: Weather, to: Weather)

@export var current_weather: Weather = Weather.NONE


var lights: Array = []


func _ready() -> void:
	target_canvas_modulate = owner.get_node("CanvasModulate")
	rain_and_snow.show()
	fog.show()
	sunny.show()
	if real_time and auto_deduction:
		timer.wait_time = 10
		timer.start()
		cycle_time = 24 * 60 * 60
		update_real_time()


func _process(delta: float) -> void:
	if auto_deduction:
		if not real_time:
			current_time += delta * 24 / cycle_time
			
	match current_weather:
		Weather.NONE:
			pass
		Weather.SUNNY:
			pass
		Weather.RAINY:
			pass
		Weather.STORMY:
			if strobe_timer.is_stopped() and Tools.is_success(0.01):
				var count = randi_range(1, 3)
				make_strobe(count)
				strobe_timer.start()
		Weather.SNOWY:
			pass
		Weather.FOGGY:
			pass
		


func transition_weather(target_weather: Weather, target_wind_speed: float, time: float) -> void:
	weather_change.emit(current_weather, target_weather)
	
	show_one_weather(target_weather, time)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(self, "wind_speed", target_wind_speed, time)

	match target_weather:
		Weather.NONE:
			pass
		Weather.SUNNY:
			set_sunny_params(target_wind_speed, time)
		Weather.RAINY:
			var hard = true
			if current_weather in [Weather.STORMY, Weather.SNOWY]: hard = false
			set_rainy_params(target_wind_speed, time, hard)
		Weather.STORMY:
			var hard = true
			if current_weather in [Weather.RAINY, Weather.SNOWY]: hard = false
			set_stormy_params(target_wind_speed, time, hard)
		Weather.SNOWY:
			set_snowy_params(target_wind_speed, time)
		Weather.FOGGY:
			set_fog_params(target_wind_speed, time)
			
	await tween.finished
			
	current_weather = target_weather

func show_one_weather(target_weather: Weather, time: float) -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	match target_weather:
		Weather.NONE:
			tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(fog.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(sunny.material, "shader_parameter/alpha", 0.0, time)
		Weather.SUNNY:
			tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(fog.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(sunny.material, "shader_parameter/alpha", randf_range(0.1, 0.3), time)
		Weather.RAINY:
			tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/alpha", 1.0, time)
			tween.parallel().tween_property(fog.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(sunny.material, "shader_parameter/alpha", 0.0, time)
		Weather.STORMY:
			tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/alpha", 0.8, time)
			tween.parallel().tween_property(fog.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(sunny.material, "shader_parameter/alpha", 0.0, time)
		Weather.SNOWY:
			tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/alpha", 0.8, time)
			tween.parallel().tween_property(fog.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(sunny.material, "shader_parameter/alpha", 0.0, time)
		Weather.FOGGY:
			tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/alpha", 0.0, time)
			tween.parallel().tween_property(fog.material, "shader_parameter/alpha", 1.0, time)
			tween.parallel().tween_property(sunny.material, "shader_parameter/alpha", 0.0, time)
			
func set_sunny_params(target_wind_speed: float, _time: float) -> void:
	
	sunny.material.set_shader_parameter("angle", randf_range(-0.3, -0.1))
	sunny.material.set_shader_parameter("position", randf_range(-0.1, 0.1))
	sunny.material.set_shader_parameter("spread", randf_range(0.3, 0.8))
	sunny.material.set_shader_parameter("cutoff", randf_range(-0.1, 0.1))
	sunny.material.set_shader_parameter("falloff", randf_range(0.2, 1.0))
	sunny.material.set_shader_parameter("edge_fade", randf_range(0.2, 0.6))
	sunny.material.set_shader_parameter("speed", randf_range(4, 10) * abs(target_wind_speed))
	sunny.material.set_shader_parameter("ray1_density", randf_range(5, 30))
	sunny.material.set_shader_parameter("ray2_density", randf_range(20, 60))
	sunny.material.set_shader_parameter("ray2_intensity", randf_range(0.2, 0.8))
			
func set_rainy_params(target_wind_speed: float, time: float, hard: bool) -> void:
	rain_and_snow.material.set_shader_parameter("rain", true)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	rain_and_snow.material.set_shader_parameter("rain_amount", randf_range(50, 80))
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_length", randf_range(0.04, 0.10), time*0.1)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_length", randf_range(0.02, 0.04), time*0.1)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_width", randf_range(0.04, 0.08), time*0.1)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_width", randf_range(0.02, 0.04), time*0.1)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_transparency", randf_range(0.4, 0.6), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_transparency", randf_range(0.4, 0.6), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/rain_color", Color(0.6, 0.6, 0.6, 1.0), time)
	rain_and_snow.material.set_shader_parameter("base_rain_speed", randf_range(0.3, 0.5))
	rain_and_snow.material.set_shader_parameter("additional_rain_speed", randf_range(0.1, 0.2))
	if hard:
		rain_and_snow.material.set_shader_parameter("slant", target_wind_speed*0.5)
	else:
		tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/slant", target_wind_speed*0.5, time)

func set_stormy_params(target_wind_speed: float, time: float, hard: bool) -> void:
	rain_and_snow.material.set_shader_parameter("rain", true)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	rain_and_snow.material.set_shader_parameter("rain_amount", randf_range(150, 250))
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_length", randf_range(0.12, 0.16), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_length", randf_range(0.04, 0.12), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_width", randf_range(0.3, 0.4), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_width", randf_range(0.2, 0.3), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_transparency", randf_range(0.4, 0.6), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_transparency", randf_range(0.4, 0.6), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/rain_color", Color(0.6, 0.6, 0.6, 1.0), time)
	rain_and_snow.material.set_shader_parameter("base_rain_speed", randf_range(0.5, 1.0))
	rain_and_snow.material.set_shader_parameter("additional_rain_speed", randf_range(0.3, 0.4))
	if hard:
		rain_and_snow.material.set_shader_parameter("slant", target_wind_speed*0.5)
	else:
		tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/slant", target_wind_speed*0.5, time)
	
func set_snowy_params(target_wind_speed: float, time: float) -> void:
	rain_and_snow.material.set_shader_parameter("rain", false)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	rain_and_snow.material.set_shader_parameter("rain_amount", randf_range(150, 250))
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_length", 0.01, time*0.1)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_length", 0.01, time*0.1)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_width", randf_range(0.6, 1.0), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_width", randf_range(0.6, 1.0), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/near_rain_transparency", randf_range(0.2, 0.8), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/far_rain_transparency", randf_range(0.2, 0.8), time)
	tween.parallel().tween_property(rain_and_snow.material, "shader_parameter/rain_color", Color(0.6, 0.6, 0.6, 1.0), time)
	rain_and_snow.material.set_shader_parameter("base_rain_speed", randf_range(0.1, 0.6))
	rain_and_snow.material.set_shader_parameter("additional_rain_speed", randf_range(0.1, 0.6))
	rain_and_snow.material.set_shader_parameter("slant", target_wind_speed*0.5)

func set_fog_params(target_wind_speed: float, time: float) -> void:
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.parallel().tween_property(fog.material, "shader_parameter/density", randf_range(0.15, 1.0), time)
	fog.material.set_shader_parameter("speed", Vector2(randf_range(-0.1, 0.1)*target_wind_speed, randf_range(-0.02, 0.02)*target_wind_speed))
	tween.parallel().tween_property(fog.material, "shader_parameter/scale", randf_range(2.0, 4.0), time)
	
func make_strobe(count: int = 1) -> void:
	for i in range(count):
		var strength = randf_range(0.2, 0.4)
		var tween_time = randf_range(0.05, 0.15)
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(strobe, "color:a", strength, tween_time).from(0.0)

		await tween.finished
		tween_time = randf_range(0.15, 0.3)
		tween = create_tween().set_trans(Tween.TRANS_LINEAR)
		tween.parallel().tween_property(strobe, "color:a", 0.0, tween_time).from(strength)
		
func register_light(light: Light2D, e0: float, e1: float, e2: float, e3: float, time: float) -> void:
	var light_dict = {
		"light": light,
		"e0": e0,
		"e1": e1,
		"e2": e2,
		"e3": e3,
		"time": time,
	}
	lights.append(light_dict)
	update_lights(current_time_type)

func update_lights(time_type: TimeType) -> void:
	if lights.size() == 0:
		return
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	
	match time_type:
		TimeType.DAYTIME:
			for light_dict in lights:
				tween.parallel().tween_property(light_dict["light"], "energy", light_dict["e0"], light_dict["time"])
		TimeType.EVENING:
			for light_dict in lights:
				tween.parallel().tween_property(light_dict["light"], "energy", light_dict["e1"], light_dict["time"])
		TimeType.LATE_NIGHT:
			for light_dict in lights:
				tween.parallel().tween_property(light_dict["light"], "energy", light_dict["e2"], light_dict["time"])
		TimeType.EARLY_MORNING:
			for light_dict in lights:
				tween.parallel().tween_property(light_dict["light"], "energy", light_dict["e3"], light_dict["time"])
		
func update_time_type() -> void:
	var target_time_type: TimeType
	if current_time >= 8 and current_time < 16:
		target_time_type = TimeType.DAYTIME
	elif current_time >= 16 and current_time < 20:
		target_time_type = TimeType.EVENING
	elif current_time >= 20 or current_time < 4:
		target_time_type = TimeType.LATE_NIGHT
	else:
		target_time_type = TimeType.EARLY_MORNING
		
	current_time_type = target_time_type
		
	
func update_real_time() -> void:
	var datetime = Time.get_datetime_dict_from_system()
	var total_seconds = datetime.hour * 3600 + datetime.minute * 60 + datetime.second
	current_time = total_seconds * 24 / cycle_time
	

func get_next_weather(_current_weather: Weather, _current_time: float) -> Weather:
	var next_weather = _current_weather
	var weather_chances = [
		[Weather.SUNNY, Weather.RAINY, Weather.FOGGY],  # NONE
		[Weather.RAINY, Weather.FOGGY, Weather.NONE],   # SUNNY
		[Weather.STORMY, Weather.SUNNY, Weather.FOGGY], # RAINY
		[Weather.RAINY, Weather.FOGGY, Weather.SUNNY],  # STORMY
		[Weather.SUNNY, Weather.FOGGY, Weather.STORMY], # SNOWY
		[Weather.SUNNY, Weather.RAINY, Weather.NONE],   # FOGGY
	]
	
	if _current_time < 8 or _current_time > 16:
		for chance in weather_chances:
			chance.erase(Weather.SUNNY)
	
	while next_weather == _current_weather:
		next_weather = weather_chances[_current_weather][randi() % weather_chances[_current_weather].size()]

	return next_weather
	
func get_next_wind_speed(current_wind_speed: float, next_weather: Weather) -> float:
	var next_wind_speed: float
	var change_interval = 0.3

	match next_weather:
		Weather.NONE:
			return randf_range(0.0, 0.1) * (1 if randf() < 0.5 else -1)
		Weather.SUNNY:
			return randf_range(0.0, 0.3) * (1 if randf() < 0.5 else -1)
		Weather.RAINY:
			pass
		Weather.STORMY:
			pass
		Weather.SNOWY:
			pass
		Weather.FOGGY:
			pass
		
	var top = clampf(current_wind_speed + change_interval, current_wind_speed, 1)
	var dowm = clampf(current_wind_speed - change_interval, -1, current_wind_speed)
	var rand_speed = randf_range(dowm, top)

	return rand_speed


func _on_timer_timeout() -> void:
	update_real_time()
	
func _on_rand_weather_timer_timeout() -> void:
	var rand_w = get_next_weather(current_weather, current_time)
	var rand_speed = get_next_wind_speed(wind_speed, rand_w)
	var rand_time = randf_range(1.0, 5.0)
	transition_weather(rand_w, rand_speed, rand_time)
	
	
func _on_button_pressed() -> void:
	var rand_w = get_next_weather(current_weather, current_time)
	var rand_speed = randf_range(-1.0, 1.0)
	var rand_time = randf_range(1.0, 5.0)
	print("weather_info: ", rand_w, " ", rand_speed, " ", rand_time)
	transition_weather(rand_w, rand_speed, rand_time)


func _on_button_2_pressed() -> void:
	transition_weather(Weather.RAINY, 0.5, 3.0)



