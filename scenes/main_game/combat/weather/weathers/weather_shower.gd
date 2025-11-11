class_name WeatherShower
extends Weather

func animate_in() -> void:
	await super.animate_in()
	Events.request_constant_water_wave_update.emit(0.05)

func animate_out() -> void:
	await super.animate_out()
	Events.request_constant_water_wave_update.emit(-0.05)
